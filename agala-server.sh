#!/bin/bash

# Configuration file location
CONFIG_FILE="$HOME/.config/agala-server/servers.json"

# Function to get server details from the JSON config file
get_server_details() {
  local alias=$1
  server_user=$(jq -r ".${alias}.user" $CONFIG_FILE)
  server_ip=$(jq -r ".${alias}.ip" $CONFIG_FILE)
  server_port=$(jq -r ".${alias}.port" $CONFIG_FILE)
}

# Function to connect via SSH
connect() {
  local alias=$1
  get_server_details $alias
  if [[ -n $server_user && -n $server_ip && -n $server_port ]]; then
    echo "Connecting to $alias ($server_ip) via SSH..."
    ssh -p $server_port $server_user@$server_ip
  else
    echo "Error: Server alias '$alias' not found or missing details."
  fi
}

# Function to upload file/folder using SCP
upload() {
  local alias=$1
  local local_path=$2
  local remote_path=$3
  get_server_details $alias
  if [[ -n $server_user && -n $server_ip && -n $server_port ]]; then
    echo "Uploading to $alias ($server_ip) using SCP..."
    scp -P $server_port -r $local_path $server_user@$server_ip:$remote_path
  else
    echo "Error: Server alias '$alias' not found or missing details."
  fi
}

# Function to download file/folder using SCP
download() {
  local alias=$1
  local remote_path=$2
  local local_path=$3
  get_server_details $alias
  if [[ -n $server_user && -n $server_ip && -n $server_port ]]; then
    echo "Downloading from $alias ($server_ip) using SCP..."
    scp -P $server_port -r $server_user@$server_ip:$remote_path $local_path
  else
    echo "Error: Server alias '$alias' not found or missing details."
  fi
}

# Parse the command
case $1 in
connect)
  if [ -z "$2" ]; then
    echo "Error: You must specify a server alias."
    exit 1
  fi
  connect $2
  ;;
upload)
  if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
    echo "Error: You must specify a server alias, local path, and remote path."
    exit 1
  fi
  upload $2 $3 $4
  ;;
download)
  if [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]; then
    echo "Error: You must specify a server alias, remote path, and local path."
    exit 1
  fi
  download $2 $3 $4
  ;;
*)
  echo "Usage: $0 {connect|upload|download} <server alias> [params]"
  ;;
esac
