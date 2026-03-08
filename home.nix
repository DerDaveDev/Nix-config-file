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

  # Bashrc overwrite
  programs.bash = {
    enable = true; # This tells Home Manager to manage your bashrc

    shellAliases = {
      # The alias name is update
      update = "flatpak update && nix-channel --update && home-manager switch";

      # Optional: A 'cleanup' alias to free up disk space
      cleanup = "nix-collect-garbage --delete-old";
    };
  };

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

    # Command line tools
    pkgs.javaPackages.compiler.openjdk17

    # GUI Apps
    (wrapGL pkgs.vscode "code")
    (wrapGL pkgs.antigravity "antigravity")

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
}
