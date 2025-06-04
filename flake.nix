# ~/nixos-config/flake.nix
{
  description = "Configuracion de NixOS para Julisa";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    blesh.url = "github:akinono/blesh";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nix-vscode-extensions, blesh, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgsUnstable = import nixpkgs-unstable { inherit system; config.allowUnfree = true; };
  in
  {
    nixosConfigurations."julixos" = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs pkgsUnstable; blesh = blesh.pkgs.${system}.default; };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit pkgsUnstable; blesh = blesh.pkgs.${system}.default; };
          home-manager.users.julisa = import ./users/julisa/home.nix;
          nixpkgs.overlays = [ nix-vscode-extensions.overlays.default ];
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };
  };
}
