#!/bin/zsh

# Completion
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit
complete -C '/usr/local/bin/aws_completer' aws

# REMOVED. Just set AWS_PROFILE in your root .zshrc instead.
# Forward call to aws cli on behalf of default admin IAM user profile
# function ssoaws {
#   aws "$@" --profile "$DEFAULT_AWS_SSO_PROFILE"
# }

# Utility Functions

function empty-and-delete-bucket {
  echo "Emptying..."
  aws s3 rm s3://$1 --recursive
  echo "Deleting..."
  aws s3api delete-bucket --bucket $1
}
