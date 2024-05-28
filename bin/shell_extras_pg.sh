# asdf
export PATH=$PATH:$HOME/.asdf/shims

# Homebrew
# This is needed to add commands like Homebrew-installed nvim to your PATH
eval $(/opt/homebrew/bin/brew shellenv)

# Utility functions

function get_ca_endpoint() {
  aws codeartifact get-repository-endpoint --domain ${PG_CA_DOMAIN} --domain-owner $PG_AWS_ACCT --repository ${PG_CA_DOMAIN} --format npm --profile $AWS_SSO_PROFILE | jq -r .repositoryEndpoint
}

function get_ca_token() {
  aws codeartifact get-authorization-token --domain ${PG_CA_DOMAIN} --domain-owner $PG_AWS_ACCT --profile $AWS_SSO_PROFILE | jq -r .authorizationToken
}

# Shorthand command for logging into an SSO profile
function build-env {
  sso_profile=$1
  aws sso login --profile $sso_profile
}

function npm_login_force() {
  ENDPOINT=$(get_ca_endpoint)
  TOKEN=$(get_ca_token)
  npm config set ${PG_PKG_ID}:registry "$ENDPOINT"
  npm config set "${ENDPOINT#"https:"}":_authToken="$TOKEN"
}

function npm_login() {
  FILETIME=$(date -r ~/.npmrc +%s)
  TIME=$(date +%s)
  if [[ $(($TIME - 43200 - $FILETIME)) > 0 ]]; then
    echo "logging into ${PG_CA_DOMAIN}'s npm"
    npm_login_force
  else
    echo $(((43200 + $FILETIME - $TIME) / 3600)).$(((43200 + $FILETIME - $TIME) % 3600)) hours before logging in to ${PG_CA_DOMAIN}\'s npm
  fi
}
