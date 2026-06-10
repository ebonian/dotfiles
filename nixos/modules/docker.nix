{pkgs, ...}: {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };

  # Use pasta instead of the default slirp4netns for rootless networking — more
  # robust to Wi-Fi/Ethernet roaming and suspend/resume on the laptop.
  systemd.user.services.docker = {
    path = [pkgs.passt]; # provides `pasta` on the rootless daemon's PATH
    environment = {
      DOCKERD_ROOTLESS_ROOTLESSKIT_NET = "pasta";
      # pasta is incompatible with the default "builtin" port driver; it needs
      # "implicit" (pasta forwards published ports) or "none" (no port mapping).
      DOCKERD_ROOTLESS_ROOTLESSKIT_PORT_DRIVER = "implicit";
    };
  };

  # Rootless dockerd only programs the conntrack / return-path FORWARD rules
  # (DOCKER-CT, DOCKER-BRIDGE) for the default docker0 bridge. User-defined
  # bridges (every compose network) get their outbound rule but NOT the
  # RELATED,ESTABLISHED return rule — so a container's SYN leaves, the SYN-ACK
  # comes back, hits the FORWARD policy DROP, and egress times out (DNS to the
  # pasta forwarder and raw IP both fail) while the host has full internet.
  # Reproduced on both Docker 27.5.1 and 28.5.1, on pre-existing and freshly
  # created networks. Forcing the rootless netns's FORWARD policy to ACCEPT
  # restores egress for all bridges; inter-network isolation is preserved
  # because the explicit DOCKER-ISOLATION rules run before the policy fallthrough.
  # The policy survives compose up/down churn, so a one-shot after start is enough.
  # nsenter must target the rootlesskit CHILD pid with -U (the netns lives in a
  # user namespace where uid 1000 maps to root); -n alone hits EPERM.
  systemd.user.services.docker-forward-accept = {
    description = "Force FORWARD policy ACCEPT in the rootless Docker netns so user-bridge containers have egress";
    after = ["docker.service"];
    wantedBy = ["docker.service"];
    path = [pkgs.util-linux pkgs.iptables pkgs.coreutils];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "docker-forward-accept" ''
        set -eu
        sd="$XDG_RUNTIME_DIR/dockerd-rootless"
        for _ in $(seq 1 50); do [ -f "$sd/child_pid" ] && break; sleep 0.2; done
        cpid="$(cat "$sd/child_pid")"
        exec nsenter -U -n --preserve-credentials -t "$cpid" -- iptables -P FORWARD ACCEPT
      '';
    };
  };
}
