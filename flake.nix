{
  description = "Project flake for Elixir/Phoenix development with postgres";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          name = "elixir-phoenix-dev-shell";
          buildInputs = [
            pkgs.elixir
            pkgs.postgresql
            pkgs.nodejs
          ];

          shellHook = ''
            echo "Welcome to the Elixir/Phoenix dev shell!"
            echo "Your global config files remain active:"

            # OPTIONAL: If you want to automatically initialize and start a temporary PostgreSQL instance,
            # you might do something like the following (adjust paths as needed):
            #
            # export PGDATA=/tmp/pgdata
            # if [ ! -f "$PGDATA" ]; then
            #   echo "Initializing a new Postgres data directory at $PGDATA"
            #   mkdir -p $PGDATA
            #   initdb -D $PGDATA
            # fi
            # echo "Starting PostgreSQL..."
            # pg_ctl -D $PGDATA -l $PGDATA/logfile start
            #
            # (Remember: This simple approach uses /tmp/pgdata. If you want separate volumes per dev shell,
            #  you'll need to configure unique PGDATA directories.)
          '';
        };
      });
}
