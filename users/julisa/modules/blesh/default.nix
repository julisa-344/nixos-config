{ pkgs, config, ... }:

let
  # Obtener blesh desde specialArgs del flake principal, con fallback a fetchFromGitHub
  blesh = config._module.args.blesh or (pkgs.fetchFromGitHub {
    owner = "akinomyoga";
    repo = "ble.sh";
    rev = "v0.4.0-devel3"; # Usar una versión específica
    sha256 = "sha256-o15mQ6eD5AuORS777M7cZfI6zFwB0dkkzeEm+WR5sEk="; # Hash correcto del error
  });
  
  drv = pkgs.stdenvNoCC.mkDerivation {
    name = "blesh";
    src = blesh;
    dontBuild = true;

    installPhase = ''
      mkdir -p "$out/share/lib"

      cat <<EOF >"$out/share/lib/_package.sh"
      _ble_base_package_type=nix
      function ble/base/package:nix/update {
        echo "Use Nix to update" >&2
        return 1
      }
      EOF

      cp -rv ./* $out/share

      runHook postInstall
    '';

    postInstall = ''
      mkdir -p "$out/bin"
      cat <<EOF >"$out/bin/blesh-path"
      #!${pkgs.runtimeShell}
      # Run this script to find the ble.sh shared folder
      # where all the shell scripts are living.
      echo "$out/share/ble.sh"
      EOF
      chmod +x "$out/bin/blesh-path"
    '';
  };
in
{
  home.packages = [ drv ];

  home.file.".blerc".source = ./.blerc;
}