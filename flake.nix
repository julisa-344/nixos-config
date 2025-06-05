{
  description = "Configuracion de NixOS para Julisa";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgsUnstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
    pkgsStable = import nixpkgs { inherit system; config.allowUnfree = true; };
  in
  {
    nixosConfigurations."julixos" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs pkgsUnstable;
        blesh = pkgsStable.blesh.src;
      };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { 
              inherit pkgsUnstable; 
              blesh = pkgsStable.blesh.src;  # ← AGREGAR ESTA LÍNEA
            };
            users.julisa = import ./users/julisa;
          };
        }
      ];
    };
  };
}