{
  description = "NotesMD CLI — terminal tool for Markdown / Obsidian-style vaults";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      systems = [ "aarch64-linux" "x86_64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
      version =
        self.shortRev or self.dirtyShortRev or "0.0.0+${self.lastModifiedDate}";
    in
    {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.buildGoModule {
            pname = "notesmd-cli";
            inherit version;
            src = ./.;
            vendorHash = null;
            meta = {
              mainProgram = "notesmd-cli";
              description = "CLI for Obsidian-style Markdown vaults without requiring Obsidian";
              homepage = "https://github.com/Yakitrak/notesmd-cli";
              license = pkgs.lib.licenses.mit;
            };
          };
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/notesmd-cli";
        };
      });

      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = [ self.packages.${system}.default ];
          };
        });
    };
}
