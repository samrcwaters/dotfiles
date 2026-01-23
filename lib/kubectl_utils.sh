#!/bin/zsh

function ksecret {
  # Fetch a secret value from kubectl and copy to clipboard
  local secret_name="$1"
  local data_key="$2"
  local namespace="${3:-default}"

  if [[ -z "$secret_name" || -z "$data_key" ]]; then
    echo "Usage: ksecret <secret-name> <data-key> [namespace]"
    return 1
  fi

  kubectl get secret "$secret_name" --namespace "$namespace" --template="{{.data.$data_key}}" | base64 --decode | pbcopy
  echo "Copied $secret_name.$data_key from namespace '$namespace' to clipboard"
}
