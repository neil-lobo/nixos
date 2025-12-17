{
  system,
  pkgs,
  ...
}:
{
  imports = [
    ../common/configuration.nix
    # ./hardware-configuration.nix
  ];

  networking = {
    hostName = "titan";
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
