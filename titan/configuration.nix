{
  system,
  pkgs,
  pkgsUnstable,
  config,
  nix-flatpak,
  ...
}:
{
  imports = [
    ../common/configuration.nix
    ./hardware-configuration.nix
    nix-flatpak.nixosModules.nix-flatpak
  ];

  boot.kernelParams = [
    "pcie_aspm=off"
  ];

  networking = {
    hostName = "titan";
    firewall = {
      allowedTCPPorts = [ 22 ];
    };
  };

  services = {
    power-profiles-daemon.enable = false;
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
    flatpak = {
      enable = true;
      packages = [
        "org.vinegarhq.Sober"
        "org.vinegarhq.Vinegar"
      ];
    };
  };

  hardware = {
    nvidia = {
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  powerManagement.cpuFreqGovernor = "performance";

  # programs = {
  #   nix-ld = {
  #     enable = true;
  #   };
  # };

  users.users.neil.packages = (import ./.shvl/unstable.nix pkgsUnstable) ++ [
    (import ./pkgs/chrome.nix { pkgs = pkgsUnstable; })
  ];

  system.stateVersion = "25.05"; # Did you read the comment?
}
