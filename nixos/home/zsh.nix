{
  pkgs,
  config,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ls = "exa --icons";
      ll = "exa --icons -l";
      la = "exa --icons -la";
      tree = "exa --icons -T";
      minecraft = "nohup prismlauncher >/dev/null 2>&1 &";
    };
    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };
    zplug = {
      enable = true;
      plugins = [
        {name = "zsh-users/zsh-autosuggestions";}
      ];
    };
    oh-my-zsh = {
      enable = true;
      plugins = ["git"];
      theme = "robbyrussell";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
