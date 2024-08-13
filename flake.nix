{
  description = "AWS CDK";

  inputs.nixpkgs.url = github:nixos/nixpkgs;

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      packages.${system}.default = pkgs.nodePackages.aws-cdk.overrideAttrs (_: {
        preRebuild = ''
          substituteInPlace lib/index.js \
          --replace 'await fs27.copy(fromFile,toFile)' 'await fs27.copy(fromFile, toFile); await fs27.chmod(toFile, 0o644);'

          tar --to-stdout -xf $src package/package.json \
          | ${pkgs.jq}/bin/jq '{"devDependencies"}' > /build/devDependencies.json
        '';
        postInstall = ''
          FIXED_PACKAGE_JSON="$(${pkgs.jq}/bin/jq -s '.[0] * .[1]' package.json /build/devDependencies.json)"
          printf "%s\n" "$FIXED_PACKAGE_JSON" > package.json
        '';
      });
    };
}
