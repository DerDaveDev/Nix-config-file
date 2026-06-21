{ config, pkgs, ... }:

let
  nixgl = import <nixgl> {};

  # This copies the whole package (icons included) but overwrites the binary to run the app with GPU support
  wrapGL = pkg: exe: pkgs.symlinkJoin {
    name = "${pkg.name}-wrapped";
    paths = [ pkg ];

    # 1. Untie the symlink to the binary so it be can replaced
    # 2. Create a wrapper script in its place
    # 3. Make it executable
    postBuild = ''
      unlink $out/bin/${exe}

      cat > $out/bin/${exe} <<EOF
      #!${pkgs.bash}/bin/bash
      exec ${nixgl.auto.nixGLDefault}/bin/nixGL ${pkg}/bin/${exe} "\$@"
      EOF

      chmod +x $out/bin/${exe}
    '';
  };
in
{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "deck";
  home.homeDirectory = "/home/deck";

  # ### ENABLE UNFREE PACKAGES (non open soruce applications) ###
  nixpkgs.config.allowUnfree = true;

  # It fixes Desktop Integration (Icons & Menus)
  # This setting configures a variable called XDG_DATA_DIRS. This acts as a bridge, telling the OS to add nix .desktop files to the menu
  targets.genericLinux.enable = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [

    # Commandline tools
    pkgs.javaPackages.compiler.openjdk17
    pkgs.scrcpy
    pkgs.ollama

    pkgs.python313Packages.pillow
    pkgs.python313Packages.numpy

    # GUI Apps
    #(wrapGL pkgs.antigravity "antigravity")
    (wrapGL pkgs.opencode-desktop "opencode-desktop")

  # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];




  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';

    ## Configure OpenCode to connect to local Ollama models
    ".config/opencode/opencode.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      provider = {
        ollama = {
          npm = "@ai-sdk/openai-compatible";
          name = "Ollama (local)";
          options = {
            # Pointing to the translation layer is necessary for the SDK
            baseURL = "http://127.0.0.1:11434/v1";
          };
          models = {
            "qwen2.5-coder:3b" = {
              name = "Qwen 2.5 Coder (3B)";
            };
            "qwen2.5-coder:7b" = {
              name = "Qwen 2.5 Coder (7B)";
            };
          };
        };
      };
    };

  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/deck/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #### Ollama Background Services
  services.ollama = {
    enable = true;
    environmentVariables = {
      HSA_OVERRIDE_GFX_VERSION = "10.3.0"; # This variable forces compatibility for the Steam Deck GPU
    };
  };
}
