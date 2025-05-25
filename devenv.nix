{ pkgs, lib, config, inputs, ... }:

{
  packages = with pkgs; [ 
    git 
    elixir
    postgresql
    nodejs_20
  ];

  services = {
    postgres = {
      enable = true;
      initialScript = ''
        CREATE ROLE postgres SUPERUSER LOGIN;
      '';
    };
  };

  languages.elixir = {
    enable = true;
  };

  enterShell = ''
    git --version
    elixir --version
  '';
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';
}
