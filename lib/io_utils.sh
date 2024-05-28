#!/bin/zsh

iterate-over-lines() {
  local cmd=$1
  local file=$2
  while IFS= read -r line
  do
    ${cmd} "$line"
  done < "$file"
}