# ~/nixos-config/flake.nix
{
  description = "Configuracion de NixOS para Julisa";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs"; # HM usa los paquetes de nixpkgs (24.05)
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    // Ya NO necesitamos blesh como un input separado aquí
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-vscode-extensions, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgsUnstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
    # Creamos una referencia a los paquetes de la versión estable (24.05)
    pkgsStable = import nixpkgs { inherit system; config.allowUnfree = true; };
  in
  {
    nixosConfigurations."julixos" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs pkgsUnstable;
        # Pasamos el CÓDIGO FUENTE de blesh desde nixpkgs (estable)
        blesh = pkgsStable.blesh.src;
      };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = {
            inherit pkgsUnstable;
            # Pasamos el CÓDIGO FUENTE de blesh desde nixpkgs (estable)
            # a tu home.nix
            blesh = pkgsStable.blesh.src;
          };
          home-manager.users.julisa = import ./users/julisa/home.nix;

          nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ];
          # Ya no necesitamos allowUnfree aquí si está en configuration.nix o home.nix
        }
      ];
    };
  };
}