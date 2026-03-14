{
  description = "nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=40ee5e1944bebdd128f9fbada44faefddfde29bd"; # 25.05
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    technorino.url = "git+https://github.com/2547techno/technorino";
    ninjabrainbot.url = "github:neil-lobo/Ninjabrain-Bot";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      technorino,
      ninjabrainbot,
      home-manager,
      nix-flatpak,
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        epoch = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system technorino;
            pkgsUnstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.neil = ./epoch/home.nix;
              };
            }
            ./epoch/configuration.nix
          ];
        };
        titan = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit
              system
              technorino
              ninjabrainbot
              nix-flatpak
              ;
            pkgsUnstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
          };
          modules = [
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.neil = ./titan/home.nix;
              };
            }
            ./titan/configuration.nix
          ];
        };
      };
    };
}
