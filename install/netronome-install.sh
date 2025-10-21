#!/usr/bin/env bash

# Copyright (c) 2021-2025 community-scripts ORG
# Author: HamletDuFromage
# License: MIT | https://github.com/HamletDuFromage/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/autobrr/netronome

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

APPLICATION="Netronome"
APP_NAME="netronome"

# Installing Dependencies
msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  tar
msg_ok "Installed Dependencies"

msg_info "Setup ${APPLICATION}"
RELEASE=$(curl -fsSL https://api.github.com/repos/autobrr/netronome/releases/latest | grep "tag_name" | awk '{print substr($2, 2, length($2)-3)}')
curl -fsSL -o "${RELEASE}.tar.gz" $(curl -s https://api.github.com/repos/autobrr/netronome/releases/${RELEASE} | grep download | grep linux_x86_64 | cut -d\" -f4)
tar -C /opt/"${APPLICATION}" -xzf "${RELEASE}.tar.gz"
echo "${RELEASE}" >/opt/"${APPLICATION}"_version.txt
msg_ok "Setup ${APPLICATION}"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/netronome.service
[Unit]
Description=netronome

[Service]
Type=simple
User=root
ExecStart=/opt/"${APPLICATION}" serve --config=/opt/"${APPLICATION}"/config.toml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable -q --now "${APPLICATION}"
msg_ok "Created Service"

motd_ssh
customize

# Cleanup
msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"
