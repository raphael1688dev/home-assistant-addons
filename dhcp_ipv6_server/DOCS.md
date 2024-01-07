# Home Assistant Add-on: DHCPv6 server

## Installation

Follow these steps to get the add-on installed on your system:

1. Navigate in your Home Assistant frontend to **Supervisor** -> **Add-on Store**.
2. Find the "DHCPv6 server" add-on and click it.
3. Click on the "INSTALL" button.

## How to use

1. Set the `domain` option, e.g., `mynetwork.local`.
2. Save the add-on configuration by clicking the "SAVE" button.
3. Start the add-on.

## Configuration

The DHCPv6 server add-on can be tweaked to your likings. This section
describes each of the add-on configuration options.

Example add-on configuration:

```yaml
  domain: home.local
  dns: 
    - 2001:4860:4860::8888
    - 2001:4860:4860::8844
  default_lease: 86400
  max_lease: 172800
  extra:
    - preferred-lifetime 604800;
    - option dhcp-renewal-time 3600;
    - option dhcp-rebinding-time 7200;
    - allow leasequery;
    - option dhcp6.info-refresh-time 21600;
  networks:
    - subnet: "3ffe:501:ffff:100::/64"
      ranges:
        - "3ffe:501:ffff:100::10 3ffe:501:ffff:100::11"
      prefixes: "3ffe:501:ffff:100::, 3ffe:501:ffff:111:: /64"
      extra: []
  hosts:
    - name: myclient
      client_id: "00:01:00:01:00:04:93:e0:00:00:00:00:a2:a2"
      addresses: "3ffe:501:ffff:100::1234"
      prefixes: "3ffe:501:ffff:101::/64, 3ffe:501:ffff:102::/64"
      name_servers: "3ffe:501:ffff:100:200:ff:fe00:4f4e"
      extra: []
    - name: otherclient
      mac: "01:00:80:a2:55:67"
      address: "3ffe:501:ffff:100::4321"
      extra: []
```

### Option: `domain` (required)

Your network domain name, e.g., `mynetwork.local` or `home.local`

### Option: `dns` (required)

The DNS servers your DHCP server gives to your clients. This option can
contain a list of servers. By default, it is configured to have Google's
public DNS servers: `2001:4860:4860::8888`, `2001:4860:4860::8844`.

### Option: `default_lease` (required)

The default time in seconds that the IP is leased to your client.
Defaults to `86400`, which is one day.

### Option: `max_lease` (required)

The max time in seconds that the IP is leased to your client.
Defaults to `172800`, which is two days.

### Option: `extra`

Here you can add extra configuration for dhcpd to use, followed by a semicolon.
The default values are the following:

```yaml
extra:
    - preferred-lifetime 604800;
    - option dhcp-renewal-time 3600;
    - option dhcp-rebinding-time 7200;
    - allow leasequery;
    - option dhcp6.info-refresh-time 21600;
```

### Option: `networks` (one item required)

This option defines settings for one or multiple networks for the DHCPv6 server
to hand out IP addresses for.

At least one network definition in your configuration is required for the
DHCPv6 server to work.

#### Option: `networks.subnet`

Your network schema/subnet. For example, if your IP addresses are `fd00::xxxx:xxxx:xxxx:xxxx`
the subnet becomes `fd00::/64`.

#### Option: `networks.ranges`

Defines the start / end IP addresses for the DHCPv6 server to lease IPs for.

#### Option: `networks.prefixes`

Defines the prefixes that the DHCPv6 server will assign to the clients.

#### Option: `networks.extra`

Here you can add additional configuration regarding the networks, followed by a semicolumn.

### Option: `hosts` (optional)

This option defines settings for one or host definitions for the DHCPv6 server.

It allows you to fix a host to a specific IPv6 address.

By default, none are configured.

#### Option: `hosts.name`

The name of the hostname you'd like to fix an address for.

#### Option: `hosts.mac`

The MAC address of the client device.

#### Option: `hosts.client_id`

The Client ID of the client device.

#### Option: `hosts.ip`

The IPv6 address you want the DHCP server to assign.

#### Option: `hosts.extra`

Here you can add additional configuration regarding the hosts, followed by a semicolumn.

## Support

In case you've found a bug, please [open an issue on our GitHub][issue].

[issue]: https://github.com/home-assistant/hassio-addons/issues
