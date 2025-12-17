{
  description = "nixos config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?rev=d2ed99647a4b195f0bcc440f76edfa10aeb3b743"; # 25.11
    # nixpkgs-legacy.url = "github:NixOS/nixpkgs?rev=d2ed99647a4b195f0bcc440f76edfa10aeb3b743"; # 25.05
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    technorino-flake.url = "git+https://github.com/2547techno/technorino";
    # home-manager.url = "github:nix-community/home-manager/release-25.11";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      technorino-flake,
      # nixpkgs-legacy,
      # home-manager
    }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations = {
        epoch = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit system technorino-flake;
            pkgsUnstable = import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            };
            # pkgsLegacy = import nixpkgs-legacy {
            #   inherit system;
            #   config.allowUnfree = true;
            # };
          };
          modules = [
            # home-manager.nixosModules.home-manager {
            #   home-manager = {
            #     useGlobalPkgs = true;
            #     useUserPackages = true;
            #     users.neil = ./epoch/home.nix;
            #   };
            # }
            ./common/configuration.nix
            ./epoch/configuration.nix
          ];
        };
      };
    };
}
