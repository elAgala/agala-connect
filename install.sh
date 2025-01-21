#!/bin/bash

REPO_URL="https://raw.githubusercontent.com/elAgala/agala-connect/master"

# Step 1: Install jq (if it's not already installed)
if ! command -v jq >/dev/null 2>&1; then
  echo "jq not found. Installing jq..."
  if [ "$(uname -s)" = "Linux" ]; then
    if [ -f /etc/lsb-release ]; then
      sudo apt-get update
      sudo apt-get install -y jq
    elif [ -f /etc/redhat-release ]; then
      sudo yum install -y jq
    else
      echo "Unsupported Linux distribution."
      exit 1
    fi
  elif [ "$(uname -s)" = "Darwin" ]; then
    brew install jq
  else
    echo "Unsupported OS for automatic jq installation."
    exit 1
  fi
else
  echo "jq is already installed."
fi

# Step 2: Create the configuration directory
CONFIG_DIR="$HOME/.config/agala-connect"
SERVERS_JSON="$CONFIG_DIR/servers.json"
mkdir -p "$CONFIG_DIR"

# Step 3: Download the agala-connect.sh script to the local bin directory
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"

echo "Downloading agala-connect.sh from GitHub..."
wget -q "$REPO_URL/agala-connect.sh" -O "$INSTALL_DIR/agala-connect"

# Step 4: Make sure the script is executable
chmod +x "$INSTALL_DIR/agala-connect"

if echo "$SHELL" | grep -q "zsh"; then
  USER_SHELL="zsh"
elif echo "$SHELL" | grep -q "bash"; then
  USER_SHELL="bash"
fi

# Check if servers.json exists
if [ ! -f "$SERVERS_JSON" ]; then
  echo "Creating $SERVERS_JSON with an example configuration..."

  # Example content for the servers.json
  cat <<EOL >"$SERVERS_JSON"
{
  "server_alias": {
    "ip": "127.0.0.1",
    "port": "22",
    "user": "agala"
  }
}
EOL

  echo "$SERVERS_JSON has been created with an example configuration."
else
  echo "$SERVERS_JSON already exists. Skipping creation."
fi

# Step 5: Add the installation directory to the PATH
if [ "$USER_SHELL" = "zsh" ]; then
  echo "Checking if $INSTALL_DIR is in PATH for Zsh..."
  if ! grep -q "$INSTALL_DIR" "$HOME/.zshrc"; then
    echo "Adding $INSTALL_DIR to PATH for Zsh..."
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >>"$HOME/.zshrc"
  else
    echo "$INSTALL_DIR is already in PATH for Zsh."
  fi
elif [ "$USER_SHELL" = "bash" ]; then
  echo "Checking if $INSTALL_DIR is in PATH for Bash..."
  if ! grep -q "$INSTALL_DIR" "$HOME/.bashrc"; then
    echo "Adding $INSTALL_DIR to PATH for Bash..."
    echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >>"$HOME/.bashrc"
  else
    echo "$INSTALL_DIR is already in PATH for Bash."
  fi
else
  echo "Unknown shell. Please add $INSTALL_DIR to your PATH manually."
fi

if [ "$USER_SHELL" = "zsh" ]; then
  echo "Please restart your terminal or run 'source ~/.zshrc' manually."
elif [ "$USER_SHELL" = "bash" ]; then
  echo "Please restart your terminal or run 'source ~/.bashrc' manually."
else
  echo "Please restart your terminal or reload your shell configuration file manually."
fi

# Step 6: Installation complete
echo "Installation complete! You can now use the 'agala-connect' command."
echo "Please configure your server details in '$CONFIG_DIR/servers.json'."
