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
      bashrcExtra = ''
        eval "$(ssh-agent -s)" > /dev/null
        ssh-add ~/.ssh/github_2547techno 2> /dev/null
        ssh-add ~/.ssh/github 2> /dev/null
      '';
    };
    git = {
      enable = true;
      userName = "neil-lobo";
      userEmail = "neil_edward_lobo@hotmail.com";
    };
  };
}
