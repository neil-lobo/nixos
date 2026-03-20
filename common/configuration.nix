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
  burn2cool = import ./pkgs/burn2cool.nix {
    inherit pkgs;
    thermalZone = 5;
  };
  khip = import ./pkgs/khip/default.nix { inherit pkgs; };
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
      # this doesnt work entirely. i got it to work after manually editing connections in qpwgraph but hard coded, no.
      # this as led me to discover that i can use any pipewire plugin for noise cancelation
      # extraConfig.pipewire."99-khip-filter" = {
      #   "context.modules" = [
      #     {
      #       name = "libpipewire-module-filter-chain";
      #       args = {
      #         "node.description" = "Khip Noise Suppression";
      #         "media.name" = "Khip Noise Suppression";
      #         "filter.graph" = {
      #           nodes = [
      #             {
      #               type = "ladspa";
      #               name = "khip_node";
      #               plugin = "${khip}/lib/ladspa/libkhip_ladspa.so";
      #               label = "khip_ladspa";
      #             }
      #           ];
      #           inputs = [ "khip_node:Input" ];
      #           outputs = [ "khip_node:Output" ];
      #         };
      #         "capture.props" = {
      #           "node.name" = "khip_input";
      #           "media.class" = "Audio/Sink"; # This makes it appear as an output you can route to
      #           "node.passive" = true; # Tells PipeWire this is a helper node
      #           "audio.channels" = 1;
      #           "audio.position" = [ "MONO" ];
      #           "target.object" = "alsa_input.usb-Logitech_G935_Gaming_Headset-00.mono-fallback";
      #         };
      #         "playback.props" = {
      #           "node.name" = "khip_output";
      #           "media.class" = "Audio/Source"; # This makes it appear as a Virtual Microphone
      #           "audio.channels" = 1;
      #           "audio.position" = [ "MONO" ];
      #         };
      #       };
      #     }
      #   ];
      # };
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
      powerManagement = {
        enable = false;
        finegrained = false;
      };
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
            technorino-derivation
            burn2cool.derivation
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
