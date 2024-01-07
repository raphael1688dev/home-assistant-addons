#!/usr/bin/env bashio
set -e

CONFIG="/data/dhcpd6.conf"
LEASES="/data/dhcpd6.lease"

bashio::log.info "Creating DHCP configuration..."

# Create main config
DEFAULT_LEASE=$(bashio::config 'default_lease')
DOMAIN=$(bashio::config 'domain')
MAX_LEASE=$(bashio::config 'max_lease')

{
    echo "option dhcp6.domain-search \"${DOMAIN}\";"

    # Create DNS Server List
    if [ "$(bashio::config 'dns')" ]
    then
        DNS=$(bashio::config 'dns|join(", ")')
    fi
    
    echo "option dhcp6.name-servers ${DNS};";
    echo "default-lease-time ${DEFAULT_LEASE};"
    echo "max-lease-time ${MAX_LEASE};"
    echo "authoritative;"
} > "${CONFIG}"




if bashio::config.has_value "extra"; then
    for i in $(bashio::config 'extra|keys'); do
        LINE=$(bashio::config "extra[${i}]")
        echo "$LINE" >> "${CONFIG}"
    done
fi

# Create networks
for network in $(bashio::config 'networks|keys'); do
    SUBNET=$(bashio::config "networks[${network}].subnet")
    RANGE=$(bashio::config "networks[${network}].ranges")
    PREFIX=$(bashio::config "networks[${network}].prefix")
    INTERFACE=$(bashio::config "networks[${network}].interface")

    {
    echo "subnet6 ${SUBNET} {"
    echo "interface ${INTERFACE};"
    } >> "${CONFIG}"

    if bashio::config.has_value "networks[${network}].ranges"; then
        for i in $(bashio::config "networks[${network}].ranges|keys"); do
            RANGE=$(bashio::config "networks[${network}].ranges[${i}]")
            echo "  range6 ${RANGE};" >> "${CONFIG}"
        done
    fi

    if bashio::config.has_value "networks[${network}].prefixes"; then
        for i in $(bashio::config "networks[${network}].prefixes|keys"); do
            PREFIX=$(bashio::config "networks[${network}].prefixes[${i}]")
            echo "  prefix6 ${PREFIX};" >> "${CONFIG}"
        done
    fi

    if bashio::config.has_value "networks[${network}].extra"; then
        for i in $(bashio::config "networks[${network}].extra|keys"); do
            echo "  $(bashio::config "networks[${network}].extra[${i}]")" >> "${CONFIG}"
        done
    fi

    echo "}" >> "${CONFIG}"
done

# Create hosts
for host in $(bashio::config 'hosts|keys'); do
    NAME=$(bashio::config "hosts[${host}].name")

    {
        echo "host ${NAME} {"
        echo "  option host-name \"${NAME}\";"
    } >> "${CONFIG}"

    if bashio::config.has_value "hosts[${host}].client_id"; then
        CLIENT_ID=$(bashio::config "hosts[${host}].client_id")
        echo "  host-identifier option dhcp6.client-id ${CLIENT_ID};" >> "${CONFIG}"
    fi

    if bashio::config.has_value "hosts[${host}].mac"; then
        MAC=$(bashio::config "hosts[${host}].mac")
        echo "  hardware ethernet ${MAC};" >> "${CONFIG}"
    fi

    if bashio::config.has_value "hosts[${host}].address"; then
        ADDRESS=$(bashio::config "hosts[${host}].address")
        echo "  fixed-address6 ${ADDRESS};" >> "${CONFIG}"
    fi

    if bashio::config.has_value "hosts[${host}].prefixes"; then
        for i in $(bashio::config "hosts[${host}].prefixes|keys"); do
            PREFIX=$(bashio::config "hosts[${host}].prefixes[${i}]")
            echo "  fixed-prefix6 ${PREFIX};" >> "${CONFIG}"
        done
    fi

    if bashio::config.has_value "hosts[${host}].name_servers"; then
        NAME_SERVERS=$(bashio::config "hosts[${host}].name_servers | join(\", \")")
        echo "  option dhcp6.name-servers ${NAME_SERVERS};" >> "${CONFIG}"
    fi

    if bashio::config.has_value "hosts[${host}].extra"; then
        for i in $(bashio::config "hosts[${host}].extra|keys"); do
            echo "  $(bashio::config "hosts[${host}].extra[${i}]")" >> "${CONFIG}"
        done
    fi

    echo "}" >> "${CONFIG}"
done

# Create database
if ! bashio::fs.file_exists "${LEASES}"; then
    touch "${LEASES}"
fi

# Start DHCP server
bashio::log.info "Starting DHCP server..."

exec /usr/sbin/dhcpd \
    -6 -f -d --no-pid \
    -lf "${LEASES}" \
    -cf "${CONFIG}" \
    < /dev/null
