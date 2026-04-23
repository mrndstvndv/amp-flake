{
  description = "Amp CLI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      version = "0.0.1776908924-gbce052";

      mkAmp = system: pkgs:
        let
          platformInfo = {
            "aarch64-darwin" = {
              platform = "darwin-arm64";
              sha256 = "1fy06hifcpvdbh0nkj64yy4k9s8fjfbljkhljzdqc60vc3m2grsv";
            };
            "x86_64-darwin" = {
              platform = "darwin-x64";
              sha256 = "072hdqda5nkxd1r2dq52n7p0v3vzjq4ipnmwhp214wcp5xymnjbk";
            };
            "aarch64-linux" = {
              platform = "linux-arm64";
              sha256 = "1yli88wa9zx5qm53dn9bac0fnzbrv0xgnljlyqg38rlfy2nz3zf9";
            };
            "x86_64-linux" = {
              platform = "linux-x64";
              sha256 = "0kzqs28wa8qga54rnxy8i83k8i6p59pkbjpwqx9b4nc7gm7rxpj6";
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
