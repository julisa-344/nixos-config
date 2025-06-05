# ~/nixos-config/flake.nix - COMENTARIO CORREGIDO
{
  description = "Configuracion de NixOS para Julisa";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    # nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions"; # Comentado por ahora
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, /*nix-vscode-extensions,*/ ... }@inputs:
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
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = {
            inherit pkgsUnstable; # pkgsUnstable will be available in home.nix <--- ARREGLADO!
            blesh = pkgsStable.blesh.src;
          };
          home-manager.users.julisa = import ./users/julisa/home.nix;
          # nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ]; # Comentado
        }
      ];
    };
  };
}