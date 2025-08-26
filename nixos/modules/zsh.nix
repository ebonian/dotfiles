{pkgs, ...}: {
  programs.zsh = {
    enable = true;
  };

  # Use zsh as default shell
  users.defaultUserShell = pkgs.zsh;
}
