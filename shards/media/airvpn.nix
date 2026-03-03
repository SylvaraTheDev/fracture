{ config, pkgs, ... }:

let
  inherit (config.fracture.user) login;

  ns = "airvpn";

  peer = {
    publicKey = "PyLCXAQT8KkM4T+dUsOQfn+Ub3pGxfGlxkIApuig+hk=";
    host = "earth3.vpn.airdns.org";
    port = 1637;
  };

  client = {
    ipv4 = "10.153.157.16/32";
    ipv6 = "fd7d:76ee:e68f:a993:1b89:e884:e70d:df80/128";
    mtu = 1320;
    dns = "10.128.0.1";
  };

  veth = {
    host = {
      name = "veth-vpn0";
      addr = "10.200.200.1/24";
    };
    ns = {
      name = "veth-vpn1";
      addr = "10.200.200.2/24";
    };
  };
in
{
  sops.secrets.airvpn-private-key = {
    sopsFile = config.fracture.secretsDir + "/vpn/airvpn.yaml";
    key = "vpn/private-key";
  };

  sops.secrets.airvpn-preshared-key = {
    sopsFile = config.fracture.secretsDir + "/vpn/airvpn.yaml";
    key = "vpn/preshared-key";
  };

  # Auto-used by ip netns exec for processes in this namespace
  environment.etc."netns/${ns}/resolv.conf".text = "nameserver ${client.dns}\n";

  systemd.services.airvpn = {
    description = "AirVPN WireGuard split tunnel";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];

    path = with pkgs; [
      iproute2
      wireguard-tools
      coreutils
    ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;

      ExecStart = pkgs.writeShellScript "airvpn-up" ''
        set -euo pipefail

        # Resolve endpoint on host (namespace DNS not available yet)
        ENDPOINT=$(${pkgs.getent}/bin/getent ahostsv4 ${peer.host} | head -1 | cut -d' ' -f1)

        # Create namespace
        ip netns add ${ns}
        ip netns exec ${ns} ip link set lo up

        # veth pair for host<->namespace access (e.g. Deluge web UI)
        ip link add ${veth.host.name} type veth peer name ${veth.ns.name}
        ip addr add ${veth.host.addr} dev ${veth.host.name}
        ip link set ${veth.host.name} up
        ip link set ${veth.ns.name} netns ${ns}
        ip netns exec ${ns} ip addr add ${veth.ns.addr} dev ${veth.ns.name}
        ip netns exec ${ns} ip link set ${veth.ns.name} up

        # WireGuard interface
        ip link add wg-airvpn type wireguard
        ip link set wg-airvpn netns ${ns}

        ip netns exec ${ns} wg set wg-airvpn \
          private-key ${config.sops.secrets.airvpn-private-key.path} \
          peer ${peer.publicKey} \
            preshared-key ${config.sops.secrets.airvpn-preshared-key.path} \
            endpoint "$ENDPOINT:${toString peer.port}" \
            allowed-ips 0.0.0.0/0,::/0 \
            persistent-keepalive 15

        ip netns exec ${ns} ip addr add ${client.ipv4} dev wg-airvpn
        ip netns exec ${ns} ip -6 addr add ${client.ipv6} dev wg-airvpn
        ip netns exec ${ns} ip link set wg-airvpn mtu ${toString client.mtu}
        ip netns exec ${ns} ip link set wg-airvpn up

        # Default routes through WireGuard
        ip netns exec ${ns} ip route add default dev wg-airvpn
        ip netns exec ${ns} ip -6 route add default dev wg-airvpn
      '';

      ExecStop = pkgs.writeShellScript "airvpn-down" ''
        ip netns delete ${ns} 2>/dev/null || true
        ip link delete ${veth.host.name} 2>/dev/null || true
      '';
    };
  };

  # Run commands inside the VPN namespace: vpn-exec deluge
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "vpn-exec" ''
      exec sudo ${pkgs.iproute2}/bin/ip netns exec ${ns} sudo -u "$USER" -- "$@"
    '')
  ];

  security.sudo.extraRules = [
    {
      users = [ login ];
      commands = [
        {
          command = "${pkgs.iproute2}/bin/ip netns exec ${ns} *";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
}
