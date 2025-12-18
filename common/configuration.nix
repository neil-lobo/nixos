{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  system,
  technorino-flake,
  ...
}:

let
  technorino = technorino-flake.packages.${system}.package;
  burn2cool = import ../pkgs/burn2cool.nix {
    inherit pkgs;
    thermalZone = 5;
  };
in
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    networkmanager.enable = true;
    extraHosts = ''
      172.64.80.1 cdn.7tv.app
    '';
  };

  time.timeZone = "America/Toronto";

  i18n.defaultLocale = "en_CA.UTF-8";

  services = {
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "";
      };
      videoDrivers = [
        "modesetting"
        "nvidia"
      ];
    };

    displayManager.sddm = {
      enable = true;
      theme = "catppuccin-mocha";
    };
    desktopManager.plasma6.enable = true;

    printing.enable = true;

    pulseaudio.enable = false;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    power-profiles-daemon = {
      enable = true;
    };

    ratbagd.enable = true;
  };

  security.rtkit.enable = true;

  networking = {
    firewall = {
      enable = true;
    };
  };

  hardware = {
    graphics.enable = true;
    nvidia = {
      modesetting.enable = true;
      powerManagement = {
        enable = false;
        finegrained = false;
      };
      open = true;
      nvidiaSettings = true;
      #      package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      #        version = "575.51.02";
      #        sha256_64bit = "sha256-XZ0N8ISmoAC8p28DrGHk/YN1rJsInJ2dZNL8O+Tuaa0=";
      #        sha256_aarch64 = "sha256-NNeQU9sPfH1sq3d5RUq1MWT6+7mTo1SpVfzabYSVMVI=";
      #        openSha256 = "sha256-NQg+QDm9Gt+5bapbUO96UFsPnz1hG1dtEwT/g/vKHkw=";
      #        settingsSha256 = "sha256-6n9mVkEL39wJj5FB1HBml7TTJhNAhS/j5hqpNGFQE4w=";
      #        persistencedSha256 = "sha256-dgmco+clEIY8bedxHC4wp+fH5JavTzyI1BI8BxoeJJI=";
      #      };

      #       package = config.boot.kernelPackages.nvidiaPackages.beta.overrideAttrs {
      #         src = pkgs.fetchurl {
      #           url = "https://download.nvidia.com/XFree86/Linux-x86_64/575.51.02/NVIDIA-Linux-x86_64-575.51.02.run";
      #           sha256 = "sha256-XZ0N8ISmoAC8p28DrGHk/YN1rJsInJ2dZNL8O+Tuaa0=";
      #         };
      #       };
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
  };

  virtualisation.docker.enable = true;

  programs = {
    firefox.enable = true;
    steam.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
    direnv.enable = true;
  };

  nixpkgs = {
    config = {
      allowUnfree = true;
      joypixels.acceptLicense = true;
      permittedInsecurePackages = [
        "ventoy-qt5-1.1.05"
        "beekeeper-studio-5.1.5"
      ];
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    bash-prompt-prefix = "(shell)";

    substituters = [
      "https://technorino.cachix.org"
    ];
    trusted-public-keys = [
      "technorino.cachix.org-1:u2mWFvgBuof1W3wr8VT5UQ10m4T1yoJb6fVnmhXf04o="
    ];
  };

  systemd.services = {
    burn2cool = burn2cool.systemd;
  };

  users = {
    groups = {
      wireshark = {
        members = [ "neil" ];
      };
    };
    users = {
      neil = {
        isNormalUser = true;
        description = "neil";
        extraGroups = [
          "networkmanager"
          "wheel"
          "docker"
        ];
        packages =
          import ./.shvl/stable.nix pkgs
          ++ import ./.shvl/unstable.nix pkgsUnstable
          ++ [
            technorino
            burn2cool.derivation
          ];
      };
    };
  };

  environment = {
    systemPackages = import ./.shvl/system.nix pkgs;
    variables = {
      CHATTERINO2_RECENT_MESSAGES_URL = "https://logs.zonian.dev/rm/%1";
      EDITOR = "vim";
      #       __NV_PRIME_RENDER_OFFLOAD="1";
      #       __NV_PRIME_RENDER_OFFLOAD_PROVIDER="NVIDIA-G0";
      #       __GLX_VENDOR_LIBRARY_NAME="nvidia";
      #       __VK_LAYER_NV_optimus="NVIDIA_only";
    };
  };
}
