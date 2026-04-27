{
  description = "Amp CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      version = "0.0.1777248626-ga45149";

      mkAmp = system: pkgs:
        let
          platformInfo = {
            "aarch64-darwin" = {
              platform = "darwin-arm64";
              sha256 = "1v78dmmwyp1yfq11mr32jwyh0825ay1rf1fgkrdcn5cb069890f5";
            };
            "x86_64-darwin" = {
              platform = "darwin-x64";
              sha256 = "08px6l5vs6n4h351x75haxlj0h1si3s2b6bra4rn5283apxg8h73";
            };
            "aarch64-linux" = {
              platform = "linux-arm64";
              sha256 = "14qijfycwm3v08bxzh2xwxi8sg2x03h2wadm3d1xy3z7yjq30kzz";
            };
            "x86_64-linux" = {
              platform = "linux-x64";
              sha256 = "0dpxj5b50cn0arfxnp3ppq3j9r57zhvrsrqjax6sdnywx655vljr";
            };
          }.${system};
          isLinux = pkgs.lib.hasSuffix "linux" system;
        in
        pkgs.stdenv.mkDerivation {
          pname = "amp";
          inherit version;

          src = pkgs.fetchurl {
            url = "https://storage.googleapis.com/amp-public-assets-prod-0/cli/${version}/amp-${platformInfo.platform}";
            sha256 = platformInfo.sha256;
          };

          dontUnpack = true;
          dontStrip = true;

          nativeBuildInputs = pkgs.lib.optionals isLinux [ pkgs.patchelf ];

          installPhase = ''
            mkdir -p $out/bin
            cp $src $out/bin/amp
            chmod +w $out/bin/amp
            chmod +x $out/bin/amp
          '' + pkgs.lib.optionalString isLinux ''
            patchelf --set-interpreter $(cat $NIX_CC/nix-support/dynamic-linker) $out/bin/amp
          '';

          meta = with pkgs.lib; {
            description = "Amp CLI";
            homepage = "https://ampcode.com";
            license = licenses.unfree;
            mainProgram = "amp";
          };
        };

    in
    {
      lib = {
        inherit mkAmp;
      };

      packages.aarch64-darwin.default = mkAmp "aarch64-darwin" nixpkgs.legacyPackages.aarch64-darwin;
      packages.aarch64-darwin.amp = self.packages.aarch64-darwin.default;
      packages.x86_64-darwin.default = mkAmp "x86_64-darwin" nixpkgs.legacyPackages.x86_64-darwin;
      packages.x86_64-darwin.amp = self.packages.x86_64-darwin.default;
      packages.aarch64-linux.default = mkAmp "aarch64-linux" nixpkgs.legacyPackages.aarch64-linux;
      packages.aarch64-linux.amp = self.packages.aarch64-linux.default;
      packages.x86_64-linux.default = mkAmp "x86_64-linux" nixpkgs.legacyPackages.x86_64-linux;
      packages.x86_64-linux.amp = self.packages.x86_64-linux.default;

      apps.aarch64-darwin.default = {
        type = "app";
        program = "${self.packages.aarch64-darwin.default}/bin/amp";
      };
      apps.x86_64-darwin.default = {
        type = "app";
        program = "${self.packages.x86_64-darwin.default}/bin/amp";
      };
      apps.aarch64-linux.default = {
        type = "app";
        program = "${self.packages.aarch64-linux.default}/bin/amp";
      };
      apps.x86_64-linux.default = {
        type = "app";
        program = "${self.packages.x86_64-linux.default}/bin/amp";
      };
    };
}
