#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Glances
# Configures Glances
# ==============================================================================
declare protocol
bashio::require.unprotected

# Ensure the configuration exists
if bashio::fs.file_exists '/config/glances/glances.conf'; then
    cp -f /config/glances/glances.conf /etc/glances.conf
else
    mkdir -p /config/glances \
        || bashio::exit.nok "Failed to create the Glances configuration directory"

    # Copy in template file
    cp /etc/glances.conf /config/glances/
fi

# Export Glances data to InfluxDB
if bashio::config.true 'influxdb.enabled'; then
    protocol='http'
    if bashio::config.true 'influxdb.ssl'; then
    protocol='https'
    fi
    # Modify the configuration
    if bashio::config.equals 'influxdb.version' '1'; then
    {
        echo "[influxdb]"
        echo "host=$(bashio::config 'influxdb.host')"
        echo "port=$(bashio::config 'influxdb.port')"
        echo "user=$(bashio::config 'influxdb.username')"
        echo "password=$(bashio::config 'influxdb.password')"
        echo "db=$(bashio::config 'influxdb.database')"
        echo "prefix=$(bashio::config 'influxdb.prefix')"
        echo "protocol=${protocol}"
    } >> /etc/glances.conf
    else
    {
        echo "[influxdb 2]"
        echo "host=$(bashio::config 'influxdb.host')"
        echo "port=$(bashio::config 'influxdb.port')"
        echo "token=$(bashio::config 'influxdb.token')"
        echo "org=$(bashio::config 'influxdb.org')"
        echo "bucket=$(bashio::config 'influxdb.bucket')"
        echo "prefix=$(bashio::config 'influxdb.prefix')"
        echo "protocol=${protocol}"
    } >> /etc/glances.conf
    fi
fi
