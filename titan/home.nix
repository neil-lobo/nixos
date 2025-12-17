{ config, pkgs, ... }:
{
  home = {
    username = "neil";
    homeDirectory = "/home/neil";
    stateVersion = "25.05";
  };

  programs = {
    home-manager.enable = true;
    bash = {
      enable = true;
      shellAliases = {
        sudo = "sudo ";
        la = "ls -lahF";
        nrs = "nixos-rebuild switch";
        sudocode = "sudo code --no-sandbox --user-data-dir=/.vscode-root/";
      };
    };
  };
}
