{pkgs, ...}: let
  searchengines = {
    "Nixpkgs" = {
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "type";
              value = "packages";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];

      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = ["@np"];
    };

    "google".metaData.alias = "@g";
  };
in {
  programs.firefox = {
    enable = true;
    profiles = {
      poon = {
        id = 0;
        name = "poon";
        isDefault = true;
        search = {
          engines = searchengines;
          force = true;
        };
      };
      noccare = {
        id = 1;
        name = "noccare";
        isDefault = false;
      };
    };
  };
}
