{
  config,
  pkgs,
  pkgsUnstable,
  lib,
  system,
  technorino,
  ...
}:

let
  technorino-derivation = technorino.packages.${system}.default;
  # burn2cool = import ./pkgs/burn2cool.nix {
  #   inherit pkgs;
  #   thermalZone = 5;
  # };
in
{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };

    kernelParams = [
      "boot.shell_on_fail"
    ];
  };

  networking = {
    networkmanager.enable = true;
    nameservers = [
      "8.8.8.8"
      "1.1.1.1"
    ];
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
        "nvidia"
        "modesetting"
      ];
    };

    resolved.enable = true;

    displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      # theme = "catppuccin-mocha";
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

    ratbagd.enable = true;

    # avahi = {
    #   enable = true;
    #   nssmdns4 = true;
    # };
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
      nvidiaSettings = true;
    };
  };

  virtualisation.docker.enable = true;

  programs = {
    firefox = {
      enable = true;
      package = pkgsUnstable.firefox;
    };
    steam.enable = true;
    appimage = {
      enable = true;
      binfmt = true;
    };
    direnv.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      fira-code
      mplus-outline-fonts.githubRelease
    ];
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

  # systemd.services = {
  #   burn2cool = burn2cool.systemd;
  # };

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
            technorino-derivation
            # burn2cool.derivation
            (import ./pkgs/discord.nix { pkgs = pkgsUnstable; })
          ];
      };
    };
  };

  environment = {
    systemPackages = import ./.shvl/system.nix pkgs;
    variables = {
      CHATTERINO2_RECENT_MESSAGES_URL = "https://logs.zonian.dev/rm/%1";
      EDITOR = "vim";
      NIXOS_OZONE_WL = "1";
      # TODO: this is used for ninjabrainbot to work in waywall. look into fixing prism/waywall instead. this is a temp fix
      LD_LIBRARY_PATH = "${
        pkgs.lib.makeLibraryPath (
          with pkgs;
          [
            libxkbcommon
            xorg.libXtst
            xorg.libX11
            xorg.libXt
            xorg.libXinerama
          ]
        )
      }:$LD_LIBRARY_PATH";
    };
  };
}
