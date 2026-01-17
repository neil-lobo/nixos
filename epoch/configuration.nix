{
  system,
  pkgs,
  ...
}:
{
  imports = [
    ../common/configuration.nix
    "${
      builtins.fetchGit {
        url = "https://github.com/NixOS/nixos-hardware.git";
        rev = "db030f62a449568345372bd62ed8c5be4824fa49";
      }
    }/lenovo/thinkpad/x1/7th-gen"
    ./hardware-configuration.nix
  ];

  networking = {
    hostName = "epoch";
  };

  services = {
    hardware.bolt.enable = true;

    blueman.enable = true;

    thermald = {
      enable = false;
      #       debug = true;
    };

    tlp = {
      enable = false;
      #       settings = {
      #         CPU_SCALING_MAX_FREQ_ON_AC = 2000000;
      #         CPU_BOOST_ON_AC = 0;
      #
      #         CPU_SCALING_MAX_FREQ_ON_BAT = 2000000;
      #         CPU_BOOST_ON_BAT = 0;
      #       };
    };

    power-profiles-daemon.enable = true;
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    nvidia = {
      prime = {
        #         sync.enable = true;
        allowExternalGpu = true;
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:10:0:0"; # do i need to use 09:01:0 ? (thunderbolt 3 port)
      };
      open = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  environment = {
    systemPackages = import ./.shvl/system.nix pkgs;
  };

  system.stateVersion = "25.05"; # Did you read the comment?
}
