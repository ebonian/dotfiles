{pkgs, ...}: {
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;

    # The docker-forward-accept oneshot below fixes raw egress, but DNS takes a
    # separate path: container -> embedded resolver 127.0.0.11 -> pasta's forwarder
    # 10.0.2.3 -> host resolvers. After the laptop roams networks, that pasta
    # forwarder goes stale and returns SERVFAIL, so containers can't resolve
    # (e.g. openrouter.ai) even though raw IP egress works. Pinning a public
    # upstream makes the embedded resolver forward to 1.1.1.1 directly (reachable
    # via the working egress), bypassing the flaky pasta DNS path. Keeps 127.0.0.11
    # so inter-container name resolution on user networks still works.
    daemon.settings.dns = ["1.1.1.1" "1.0.0.1"];
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
  #
  # CORRECTION (2026-06-10): the FORWARD *policy* does NOT survive network churn.
  # `docker compose up` (e.g. `just up`) recreates a network and rootless dockerd
  # resets the policy back to DROP — so a one-shot `-P FORWARD ACCEPT` after daemon
  # start silently lapses on the next compose-up and egress dies again (engine ->
  # OpenRouter: "API call failed after N retries: Connection error"). The durable fix
  # is to ALSO place the egress ACCEPTs in the DOCKER-USER chain, which Docker never
  # flushes on network create/remove — so they survive churn without this unit
  # re-running. We still set the policy for an immediate baseline.
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
        ipt() { nsenter -U -n --preserve-credentials -t "$cpid" -- iptables "$@"; }
        # Immediate baseline: open the FORWARD policy for all bridges right now.
        ipt -P FORWARD ACCEPT
        # Durable across `docker compose up` / `just up` network churn: the DOCKER-USER
        # chain is never flushed by Docker on network create/remove. Accept egress out the
        # pasta uplink (tap0) + the conntrack return path; br->br is left untouched so
        # DOCKER-ISOLATION still enforces inter-network isolation. Idempotent (-C guard).
        ipt -C DOCKER-USER -o tap0 -j ACCEPT 2>/dev/null \
          || ipt -I DOCKER-USER -o tap0 -j ACCEPT
        ipt -C DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null \
          || ipt -I DOCKER-USER -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
      '';
    };
  };
}
