{
  system,
  pkgs,
  pkgsUnstable,
  config,
  nix-flatpak,
  ninjabrainbot,
  ...
}:
let
  ninjabrainbot-derivation = ninjabrainbot.packages.${system}.default;
in
{
  imports = [
    ../common/configuration.nix
    ./hardware-configuration.nix
    nix-flatpak.nixosModules.nix-flatpak
  ];

  # boot.kernelParams = [
  #   "pcie_aspm=off"
  # ];

  hardware = {
    graphics = {
      enable32Bit = true;
    };
  };

  networking = {
    hostName = "titan";
    # firewall = {
    #   allowedTCPPorts = [ 22 ];
    # };
  };

  services = {
    # power-profiles-daemon.enable = false;
    # openssh = {
    #   enable = true;
    #   ports = [ 22 ];
    #   settings = {
    #     PasswordAuthentication = false;
    #     AllowUsers = [ "neil" ];
    #     X11Forwarding = true;
    #   };
    # };
    # avahi = {
    #   publish = {
    #     enable = true;
    #     workstation = true;
    #     addresses = true;
    #   };
    # };
    flatpak = {
      enable = true;
      packages = [
        "org.vinegarhq.Sober"
        "org.vinegarhq.Vinegar"
        "org.gnome.baobab"
      ];
    };
    pipewire.extraConfig.pipewire."00-rnnoise.conf" = {
      "context.modules" = [
        {
          "name" = "libpipewire-module-filter-chain";
          "args" = {
            "node.description" = "Noise Cancelling source";
            "media.name" = "Noise Cancelling source";
            "filter.graph" = {
              "nodes" = [
                {
                  "type" = "ladspa";
                  "name" = "rnnoise";
                  "plugin" = "${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so";
                  "label" = "noise_suppressor_stereo";
                  "control" = {
                    "VAD Threshold (%)" = 50.0;
                    "VAD Grace Period (ms)" = 1000;
                    "Retroactive VAD Grace (ms)" = 100;
                  };
                }
              ];
            };
            "audio.position" = [
              "FL"
              "FR"
            ];
            "capture.props" = {
              "node.name" = "capture.rnnoise_source";
              "node.passive" = true;
              "audio.rate" = 48000;
            };
            "playback.props" = {
              "node.name" = "rnnoise_source";
              "media.class" = "Audio/Source";
              "media.role" = "Communication";
              "audio.rate" = 48000;
            };
          };
        }
      ];
    };
  };

  hardware = {
    nvidia = {
      open = false;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
  };

  # powerManagement.cpuFreqGovernor = "performance";

  programs = {
    nix-ld = {
      enable = true;
    };
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
           action.id == "org.freedesktop.udisks2.filesystem-mount-system") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  users.users.neil.packages =
    (import ./.shvl/unstable.nix pkgsUnstable)
    ++ (import ./.shvl/stable.nix pkgs)
    ++ [
      (import ./pkgs/chrome.nix { pkgs = pkgsUnstable; })
      ninjabrainbot-derivation
    ];

  system.stateVersion = "25.05"; # Did you read the comment?
}
