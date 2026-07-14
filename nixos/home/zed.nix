{
  inputs,
  pkgs,
  ...
}: let
  dev = import inputs.nixpkgs-dev {
    system = pkgs.system;
    config.allowUnfree = true;
  };
in {
  home.packages = [dev.zed-editor-fhs];

  home.file.".config/zed/settings.json" = {
    text = builtins.toJSON {
      ui_font_family = "CaskaydiaCove Nerd Font";
      buffer_font_family = "CaskaydiaCove Nerd Font";
      edit_predictions.provider = "none";
      ui_font_size = 16;
      buffer_font_size = 18;
      theme = {
        mode = "dark";
        light = "One Light";
        dark = "Vercel Dark";
      };
      vim_mode = true;
      relative_line_numbers = "enabled";
    };
  };
}
