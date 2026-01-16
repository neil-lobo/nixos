{
  system,
  pkgs,
  pkgsUnstable,
  config,
  ...
}:
{
  imports = [
    ../common/configuration.nix
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "titan";
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
  };

  services = {
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        AllowUsers = [ "neil" ];
        X11Forwarding = true;
      };
    };
    avahi = {
      publish = {
        enable = true;
        workstation = true;
        addresses = true;
      };
    };
  };

  hardware = {
    nvidia = {
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  # programs = {
  #   nix-ld = {
  #     enable = true;
  #   };
  # };

  users.users.neil.packages = import ./.shvl/unstable.nix pkgsUnstable;

  system.stateVersion = "25.05"; # Did you read the comment?
}
