#!/bin/zsh

# Utility to update .env files with AWS credentials from login cache.
# Useful for repos that need AWS_ environment variables but you want
# to use short-lived creds from `aws login` instead of long-lived keys.

# Colors for output
_AWS_CREDS_RED='\033[0;31m'
_AWS_CREDS_GREEN='\033[0;32m'
_AWS_CREDS_YELLOW='\033[1;33m'
_AWS_CREDS_NC='\033[0m'

# Update .env file with AWS credentials from login cache
# Usage: update-aws-credentials [path/to/.env]
# If no path provided, defaults to .env in current directory
function update-aws-credentials {
  local env_file="${1:-.env}"
  local cache_dir="$HOME/.aws/login/cache"

  # Check for jq
  if ! command -v jq &> /dev/null; then
    echo -e "${_AWS_CREDS_RED}Error: jq is required but not installed${_AWS_CREDS_NC}"
    return 1
  fi

  # Check cache directory
  if [ ! -d "$cache_dir" ]; then
    echo -e "${_AWS_CREDS_RED}Error: AWS login cache directory not found at $cache_dir${_AWS_CREDS_NC}"
    echo -e "${_AWS_CREDS_YELLOW}Have you run 'aws login'?${_AWS_CREDS_NC}"
    return 1
  fi

  # Find newest cache file
  local newest_cache=$(ls -t "$cache_dir"/*.json 2>/dev/null | head -1)

  if [ -z "$newest_cache" ]; then
    echo -e "${_AWS_CREDS_RED}Error: No cache files found in $cache_dir${_AWS_CREDS_NC}"
    echo -e "${_AWS_CREDS_YELLOW}Run 'aws login' to refresh credentials${_AWS_CREDS_NC}"
    return 1
  fi

  echo -e "${_AWS_CREDS_GREEN}Found cache file: $(basename "$newest_cache")${_AWS_CREDS_NC}"

  # Extract credentials (nested under .accessToken)
  local access_key_id=$(jq -r '.accessToken.accessKeyId' "$newest_cache")
  local secret_access_key=$(jq -r '.accessToken.secretAccessKey' "$newest_cache")
  local session_token=$(jq -r '.accessToken.sessionToken' "$newest_cache")
  local expires_at=$(jq -r '.accessToken.expiresAt' "$newest_cache")

  # Validate we got real values
  if [ "$access_key_id" = "null" ] || [ -z "$access_key_id" ]; then
    echo -e "${_AWS_CREDS_RED}Error: Could not extract credentials from cache file${_AWS_CREDS_NC}"
    return 1
  fi

  echo -e "${_AWS_CREDS_YELLOW}Credentials expire at: $expires_at${_AWS_CREDS_NC}"

  # Create .env if it doesn't exist
  if [ ! -f "$env_file" ]; then
    touch "$env_file"
    echo -e "${_AWS_CREDS_GREEN}Created $env_file${_AWS_CREDS_NC}"
  else
    # Backup existing .env
    cp "$env_file" "$env_file.backup"
    echo -e "${_AWS_CREDS_GREEN}Backed up existing .env to .env.backup${_AWS_CREDS_NC}"

    # Remove old AWS credential entries
    sed -i.tmp '/^AWS_ACCESS_KEY_ID=/d' "$env_file"
    sed -i.tmp '/^AWS_SECRET_ACCESS_KEY=/d' "$env_file"
    sed -i.tmp '/^AWS_SESSION_TOKEN=/d' "$env_file"
    sed -i.tmp '/^# AWS Credentials - Expires:/d' "$env_file"
    rm -f "$env_file.tmp"
  fi

  # Append new credentials
  cat >> "$env_file" << EOF

# AWS Credentials - Expires: $expires_at
AWS_ACCESS_KEY_ID=$access_key_id
AWS_SECRET_ACCESS_KEY=$secret_access_key
AWS_SESSION_TOKEN=$session_token
EOF

  echo -e "${_AWS_CREDS_GREEN}Updated $env_file with fresh AWS credentials${_AWS_CREDS_NC}"
  echo -e "${_AWS_CREDS_YELLOW}Note: These credentials will expire at $expires_at${_AWS_CREDS_NC}"
}

# Export credentials to current shell session
# Usage: export-aws-credentials
function export-aws-credentials {
  local cache_dir="$HOME/.aws/login/cache"

  if ! command -v jq &> /dev/null; then
    echo -e "${_AWS_CREDS_RED}Error: jq is required but not installed${_AWS_CREDS_NC}"
    return 1
  fi

  if [ ! -d "$cache_dir" ]; then
    echo -e "${_AWS_CREDS_RED}Error: AWS login cache directory not found${_AWS_CREDS_NC}"
    return 1
  fi

  local newest_cache=$(ls -t "$cache_dir"/*.json 2>/dev/null | head -1)

  if [ -z "$newest_cache" ]; then
    echo -e "${_AWS_CREDS_RED}Error: No cache files found${_AWS_CREDS_NC}"
    return 1
  fi

  export AWS_ACCESS_KEY_ID=$(jq -r '.accessToken.accessKeyId' "$newest_cache")
  export AWS_SECRET_ACCESS_KEY=$(jq -r '.accessToken.secretAccessKey' "$newest_cache")
  export AWS_SESSION_TOKEN=$(jq -r '.accessToken.sessionToken' "$newest_cache")

  local expires_at=$(jq -r '.accessToken.expiresAt' "$newest_cache")
  echo -e "${_AWS_CREDS_GREEN}Exported AWS credentials to current shell${_AWS_CREDS_NC}"
  echo -e "${_AWS_CREDS_YELLOW}Expires: $expires_at${_AWS_CREDS_NC}"
}
