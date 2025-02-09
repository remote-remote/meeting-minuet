{
  description = "Project flake for Elixir/Phoenix development with a zsh dev shell";

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
          # Only include Elixir (which provides Mix) and phx.new.
          # (We omit zsh and neovim so that users can stick to their global versions.)
          buildInputs = [
            pkgs.elixir
            pkgs.postgresql
            pkgs.zsh  # we include zsh so we can re-exec into the nix-provided shell
          ];

          shellHook = ''
            echo "Welcome to the Elixir/Phoenix dev shell!"
            echo "Your global config files remain active:"
            # If you want the dev shell to always run zsh (and so source your ~/.zshrc), re-exec if not already zsh.
            if [ -z "$ZSH_VERSION" ]; then
              echo "Switching to zsh..."
              exec zsh -l
            fi

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
