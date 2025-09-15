#!/bin/bash
set -euo pipefail
trap 'echo "[ERROR] ${BASH_SOURCE[0]}:$LINENO step failed"; exit 1' ERR

[[ -f ./intro.txt ]] && cat ./intro.txt || true
echo "Welcome to the DROID setup process."

read -p "Is this your first time setting up the machine? (yes/no): " first_time

if [[ "${first_time}" == "yes" ]]; then
  echo "Great! Let's proceed with the setup."

  echo "Repulling all submodules."
  ROOT_DIR="$(git rev-parse --show-toplevel)"
  cd "${ROOT_DIR}"
  git submodule sync --recursive
  git submodule update --init --recursive

  echo -e "\n[1/4] Install Docker & Compose\n"
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update -y
  sudo apt-get install -y ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -y
  sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  sudo systemctl enable docker

  echo -e "\n[2/4] Kernel realtime / performance tuning\n"
  . /etc/os-release || true
  # Jetson/Orin에선 RT 커널 스킵
  if [[ "${ID:-}" == "ubuntu" && "${VERSION_CODENAME:-}" != "focal" && "${VERSION_CODENAME:-}" != "jammy" && -n "${UBUNTU_PRO_TOKEN:-}" ]]; then
    sudo apt-get update -y
    sudo apt-get install -y ubuntu-advantage-tools
    sudo pro attach "${UBUNTU_PRO_TOKEN}" || true
    sudo pro enable realtime-kernel || true
  else
    echo "Skipping Ubuntu Pro RT kernel (Jetson/Ubuntu ${VERSION_CODENAME:-unknown})."
  fi

  echo -e "\n[3/4] Set CPU governor\n"
  sudo apt-get install -y cpufrequtils
  sudo systemctl disable ondemand || true
  sudo systemctl enable cpufrequtils || true
  echo "GOVERNOR=performance" | sudo tee /etc/default/cpufrequtils >/dev/null
  sudo systemctl daemon-reload && sudo systemctl restart cpufrequtils || true

  command -v nvpmodel &>/dev/null && sudo nvpmodel -m 0 || true
  command -v jetson_clocks &>/dev/null && sudo jetson_clocks || true
else
  echo -e "\nWelcome back!\n"
fi

echo -e "\n[4/4] Load parameters from parameters.py\n"
PARAMETERS_FILE="$(git rev-parse --show-toplevel)/droid/misc/parameters.py"
awk -F'[[:space:]]*=[[:space:]]*' \
  '/^[[:space:]]*([[:alnum:]_]+)[[:space:]]*=/ && $1 != "ARUCO_DICT" { gsub("\"", "", $2); print "export " $1 "=" $2 }' \
  "${PARAMETERS_FILE}" > /tmp/droid_env.sh
# 환경변수 일괄 export
set -a
# shellcheck disable=SC1091
source /tmp/droid_env.sh
set +a
rm -f /tmp/droid_env.sh

export ROOT_DIR
export NUC_IP="${nuc_ip}"
export ROBOT_IP="${robot_ip}"
export LAPTOP_IP="${laptop_ip}"
export SUDO_PASSWORD="${sudo_password}"
export ROBOT_TYPE="${robot_type}"
export ROBOT_SERIAL_NUMBER="${robot_serial_number}"
export HAND_CAMERA_ID="${hand_camera_id:-}"
export VARIED_CAMERA_1_ID="${varied_camera_1_id:-}"
export VARIED_CAMERA_2_ID="${varied_camera_2_id:-}"
export UBUNTU_PRO_TOKEN="${ubuntu_pro_token:-}"

if [[ "${ROBOT_TYPE}" == "panda" ]]; then
  export LIBFRANKA_VERSION=0.9.0
else
  export LIBFRANKA_VERSION=0.10.0
fi

read -p "Do you want to rebuild the container image? (yes/no): " rebuild
if [[ "${rebuild}" == "yes" ]]; then
  echo -e "\n[Build] control server container\n"
  DOCKER_COMPOSE_DIR="${ROOT_DIR}/.docker/nuc"
  DOCKER_COMPOSE_FILE="${DOCKER_COMPOSE_DIR}/docker-compose-nuc.yaml"
  cd "${DOCKER_COMPOSE_DIR}"
  # 첫 실행은 sudo docker 권장 (그 뒤 docker 그룹 추가 가능)
  sudo docker compose -f "${DOCKER_COMPOSE_FILE}" build
fi

echo -e "\n[Net] set static IP\n"
echo "Select an Ethernet interface to set a static IP for:"
interfaces=$(ip -o link show | awk -F': ' '/(en|eth|ens|eno|enp)/{print $2}')
select interface_name in $interfaces; do
  [[ -n "${interface_name:-}" ]] && break || echo "Invalid selection."
done
echo "You've selected: ${interface_name}"

sudo nmcli connection delete "nuc_static" 2>/dev/null || true
sudo nmcli connection add con-name "nuc_static" ifname "${interface_name}" type ethernet
gw_guess="$(echo "${NUC_IP}" | awk -FS. '{printf "%s.%s.%s.1",$1,$2,$3}')"
sudo nmcli connection modify "nuc_static" \
  ipv4.method manual ipv4.addresses "${NUC_IP}/24" ipv4.gateway "${gw_guess}" \
  ipv4.dns "8.8.8.8,1.1.1.1" ipv6.method ignore
sudo nmcli connection up "nuc_static" || sudo nmcli device connect "${interface_name}" || true
echo "Static IP configuration complete for interface ${interface_name}."

echo -e "\n[Run] control server\n"
DOCKER_COMPOSE_FILE="$(git rev-parse --show-toplevel)/.docker/nuc/docker-compose-nuc.yaml"
sudo docker compose -f "${DOCKER_COMPOSE_FILE}" up -d
echo "[DONE] NUC/Orin setup complete."

# (선택) 이후 무sudo로 docker 쓰고 싶다면:
# sudo usermod -aG docker "$USER"
# newgrp docker
