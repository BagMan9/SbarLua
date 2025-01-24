{
  description = "Sketchybar lua api wrapper";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachSystem [ "aarch64-darwin" "x86_64-darwin" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        arch = if system == "aarch64-darwin" then "arm64" else "x86_64";
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "sketchybar-lua";
          version = "0.1.0";

          src = self;

          buildInputs = with pkgs; [
            lua5_4
          ];

          nativeBuildInputs = with pkgs; [
            pkg-config
            darwin.apple_sdk.frameworks.CoreFoundation
          ];

          prePatch = ''
            substituteInPlace makefile \
              --replace "$(LUA_DIR)/src -Lbin" "${pkgs.lua5_4}/include/ -L${pkgs.lua5_4}/lib" \
              --replace "$(ARCH)" "${arch}" \
              --replace "bin/liblua.a" "" \
              --replace "$(HOME)/.local/share/sketchybar_lua" "$out/lib/lua/5.4"
          '';

          buildPhase = ''
            mkdir -p bin
            make bin/sketchybar.so
          '';

          installPhase = ''
            mkdir -p $out/lib/lua/5.4
            install -Dm755 bin/sketchybar.so $out/lib/lua/5.4/
          '';

          meta = with pkgs.lib; {
            description = "lua bindings for sketchybar";
            platforms = platforms.darwin;
            license = licenses.mit;
          };
        };
      }
    );
}
