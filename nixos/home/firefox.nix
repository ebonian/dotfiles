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

    "Google".metaData.alias = "@g";
  };
in {
  home.file.".mozilla/firefox/default/chrome" = {
    source = ./firefox/chrome;
    recursive = true;
  };

  programs.firefox = {
    enable = true;
    profiles = {
      default = {
        id = 0;
        name = "default";
        isDefault = true;
        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        };
        search = {
          engines = searchengines;
          force = true;
        };
      };
    };
  };
}
