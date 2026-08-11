{pkgs, ...}: let
  # Claude Code pastes images by shelling out to `xclip`/`wl-paste` on whichever
  # host it runs on. In an SSH session that is the remote box, whose clipboard is
  # not the one you screenshotted into. This service exposes *this* machine's
  # clipboard on a loopback port; remotes reach it through a `RemoteForward`
  # declared per-host in ~/.ssh/config, and answer their own xclip calls with it.
  port = 47777;

  handler = pkgs.writeShellScript "clipboard-bridge-handler" ''
    set -u
    export PATH=${pkgs.wl-clipboard}/bin:$PATH

    # socat may start us before the compositor exports WAYLAND_DISPLAY, so
    # resolve the socket per connection rather than once at service start.
    if [ -z "''${WAYLAND_DISPLAY:-}" ]; then
      for sock in "$XDG_RUNTIME_DIR"/wayland-*; do
        [ -S "$sock" ] || continue
        WAYLAND_DISPLAY=''${sock##*/}
        export WAYLAND_DISPLAY
        break
      done
    fi

    # One request per connection: a single line naming what the caller wants.
    IFS= read -r req || exit 1
    req=''${req%$'\r'}

    case "$req" in
      TARGETS) exec wl-paste --list-types ;;
      text) exec wl-paste --no-newline ;;
      primary) exec wl-paste --primary --no-newline ;;
      image/*) exec wl-paste --type "$req" ;;
      *) exit 1 ;;
    esac
  '';
in {
  systemd.user.services.clipboard-bridge = {
    Unit = {
      Description = "Serve the local clipboard to SSH remotes on 127.0.0.1:${toString port}";
      After = ["graphical-session.target"];
    };

    Service = {
      ExecStart = "${pkgs.socat}/bin/socat TCP-LISTEN:${toString port},bind=127.0.0.1,reuseaddr,fork EXEC:${handler}";
      Restart = "always";
      RestartSec = 2;
    };

    Install.WantedBy = ["default.target"];
  };

  # Payload for the remote side — copy to ~/bin/xclip on any host you want to
  # paste images into. See the header of the script for the install command.
  home.file.".local/share/clipboard-bridge/xclip" = {
    source = ./clipboard-bridge/xclip;
    executable = true;
  };
}
