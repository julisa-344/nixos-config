# ~/nixos-config/flake.nix - LA VERSIÓN FINAL
{
  description = "Configuracion de NixOS para Julisa";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # --- ESTA ES LA LÍNEA QUE CAMBIAMOS ---
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-vscode-extensions, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgsUnstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
    pkgsStable = import nixpkgs { inherit system; config.allowUnfree = true; };
  in
  {
    nixosConfigurations."julixos" = nixpkgs.lib.nixosSystem {
      # ... el resto del archivo es idéntico y correcto ...
      inherit system;
      specialArgs = {
        inherit inputs pkgsUnstable;
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
            blesh = pkgsStable.blesh.src;
          };
          home-manager.users.julisa = import ./users/julisa/home.nix;
          nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ];
        }
      ];
    };
  };
}