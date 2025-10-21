#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/HamletDuFromage/ProxmoxVED/main/misc/build.func)
# Copyright (c) 2021-2025 community-scripts ORG
# Author: HamletDuFromage
# License: MIT | https://github.com/HamletDuFromage/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/autobrr/netronome

# App Default Values
APP="Netronome"
var_tags="${var_tags:-monitoring;network,analytics}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-1024}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -f /opt/netronome ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  RELEASE=$(curl -fsSL https://api.github.com/repos/autobrr/netronome/releases/latest | grep tag_name | cut -d\" -f4 | tr -d 'v')
  CURRENT=$(netronome version 2>/dev/null | grep -Eo 'v?[0-9]+\.[0-9]+\.[0-9]+' | tr -d 'v')

  if check_for_gh_release "netronome" "autobrr/netronome"; then
    msg_info "Stopping Service"
    systemctl stop netronome
    msg_ok "Stopped Service"

    msg_info "Updating $APP to v${RELEASE}"
    netronome update
    msg_ok "Updated $APP to v${RELEASE}"

    msg_info "Starting $APP"
    systemctl start netronome
    msg_ok "Started $APP"

    msg_ok "Update Successful"
  else
    msg_ok "No update required. ${APP} is already at v${RELEASE}"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:7575${CL}"
