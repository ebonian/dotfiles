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
  programs.vscode = {
    enable = true;
    package = dev.vscodium-fhs;

    # Keep the extensions directory managed manually (mutable) so extensions
    # installed via the GUI — and auto-updaters like claude-code/supermaven —
    # keep working untouched. Only settings are declarative.
    mutableExtensionsDir = true;

    # Declarative settings.json. Dotted keys are quoted so they stay flat JSON
    # keys rather than being expanded into nested objects.
    profiles.default.userSettings = {
      "extensions.experimental.affinity" = {
        "asvetliakov.vscode-neovim" = 1;
      };
      "editor.fontSize" = 20;
      "workbench.sideBar.location" = "right";
      "workbench.iconTheme" = "material-icon-theme";
      "editor.fontFamily" = "CaskaydiaCove Nerd Font";
      "[jsonc]" = {
        "editor.defaultFormatter" = "vscode.json-language-features";
      };
      "editor.fontLigatures" = true;
      "[css]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "editor.formatOnSave" = true;
      "[scss]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "window.menuBarVisibility" = "toggle";
      "window.titleBarStyle" = "native";
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "editor.lineNumbers" = "relative";
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "workbench.colorTheme" = "AMOLED";
      "svelte.enable-ts-plugin" = true;
      "remote.SSH.remotePlatform" = {
        "pi@192.168.31.142" = "linux";
      };
      "editor.minimap.enabled" = false;
      "workbench.activityBar.location" = "top";
      "workbench.layoutControl.enabled" = false;
      "[json]" = {
        "editor.defaultFormatter" = "vscode.json-language-features";
      };
      "camouflage.enabled" = false;
      "python.languageServer" = "Default";
      "claudeCode.preferredLocation" = "panel";
      "claudeCode.selectedModel" = "default";
      "window.commandCenter" = false;
      "window.customTitleBarVisibility" = "never";
    };
  };
}
