{
  description = "flake.nix for QwicClick-App";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      PORT = "3310";
    in
    {
      packages.${system}.default = pkgs.buildNpmPackage rec {
        pname = "qwic-click-app";
        version = "0.0.1";
        description = "The QwicClick Web App";

        src = ./.;
        npmDepsHash = "sha256-J9FAnSnDpJQLO7T8V0oBh4oA23GdTmhLoHC+mEaakyg=";
        # npmDepsHash = pkgs.lib.fakeHash;

        inherit PORT;

        nativeBuildInputs = with pkgs; [
          makeWrapper
        ];

        buildPhase = ''
          npm run build
          
          mkdir -p $out/bin
          mkdir -p $out/lib/${pname}

          mv build $out/lib/${pname}/build
          # mv package.json $out/lib/${pname}/package.json
          # mv package-lock.json $out/lib/${pname}/package-lock.json
        '';

        installPhase = ''
          makeWrapper ${pkgs.nodejs}/bin/node $out/bin/${pname} --add-flags $out/lib/${pname}/build --set PORT ${PORT}
        '';
      };

      devShells.${system}.default = pkgs.mkShell {
        name = "QwC";
        buildInputs = with pkgs; [
          nodejs
        ];
        inherit PORT;
      };
    };
}
