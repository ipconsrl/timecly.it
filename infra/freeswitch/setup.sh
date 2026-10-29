#!/usr/bin/env bash
# Creates ./conf from the FreeSWITCH vanilla config and applies Timecly settings.
# Idempotent: safe to run again after changing .env.
set -euo pipefail
cd "$(dirname "$0")"

[ -f .env ] || { cp .env.example .env; chmod 600 .env; }
for var in DEFAULT_PASSWORD ESL_PASSWORD; do
  if ! grep -q "^$var=..*" .env; then
    sed -i "s|^$var=.*|$var=$(openssl rand -hex 16)|" .env
  fi
done
set -a; . ./.env; set +a

if [ ! -f conf/freeswitch.xml ]; then
  mkdir -p conf
  docker compose run --rm --no-deps --entrypoint sh freeswitch \
    -c 'cp -a /usr/share/freeswitch/conf/vanilla/. /etc/freeswitch/'
  echo "Vanilla config copied to ./conf"
fi
sudo chown -R "$(id -u):$(id -g)" conf

set_var() { # set_var name value  (vars.xml X-PRE-PROCESS set/stun-set)
  sed -i -E "s#<X-PRE-PROCESS cmd=\"(stun-)?set\" data=\"$1=[^\"]*\"/>#<X-PRE-PROCESS cmd=\"set\" data=\"$1=$2\"/>#" conf/vars.xml
}
set_var default_password "$DEFAULT_PASSWORD"
set_var external_rtp_ip "$PUBLIC_IP"
set_var external_sip_ip "$PUBLIC_IP"
set_var internal_sip_port "$INTERNAL_SIP_PORT"
set_var external_sip_port "$EXTERNAL_SIP_PORT"
# Italian carriers use G.711 A-law
set_var global_codec_prefs "PCMA,PCMU,OPUS,G722"
set_var outbound_codec_prefs "PCMA,PCMU,G722"

# RTP port range
sed -i -E \
  -e "s#(<!-- *)?<param name=\"rtp-start-port\" value=\"[0-9]+\"/>( *-->)?#<param name=\"rtp-start-port\" value=\"$RTP_START\"/>#" \
  -e "s#(<!-- *)?<param name=\"rtp-end-port\" value=\"[0-9]+\"/>( *-->)?#<param name=\"rtp-end-port\" value=\"$RTP_END\"/>#" \
  conf/autoload_configs/switch.conf.xml

# Event socket: localhost only, random password
sed -i -E \
  -e "s#<param name=\"listen-ip\" value=\"[^\"]*\"/>#<param name=\"listen-ip\" value=\"127.0.0.1\"/>#" \
  -e "s#<param name=\"password\" value=\"[^\"]*\"/>#<param name=\"password\" value=\"$ESL_PASSWORD\"/>#" \
  conf/autoload_configs/event_socket.conf.xml

# No IPv6 profiles, no sample gateway
for f in sip_profiles/internal-ipv6.xml sip_profiles/external-ipv6.xml sip_profiles/external/example.xml; do
  if [ -f "conf/$f" ]; then mv "conf/$f" "conf/$f.disabled"; fi
done

# Firewall: internal profile from LAN only; external profile and RTP open
# (pfSense restricts them to the SIP provider IPs)
sudo ufw allow from "$LAN_CIDR" to any port "$INTERNAL_SIP_PORT" proto udp comment 'sip internal' >/dev/null
sudo ufw allow from "$LAN_CIDR" to any port "$INTERNAL_SIP_PORT" proto tcp comment 'sip internal' >/dev/null
sudo ufw allow "$EXTERNAL_SIP_PORT"/udp comment 'sip trunks' >/dev/null
sudo ufw allow "$EXTERNAL_SIP_PORT"/tcp comment 'sip trunks' >/dev/null
sudo ufw allow "$RTP_START:$RTP_END"/udp comment 'rtp' >/dev/null

echo "FreeSWITCH config ready"
