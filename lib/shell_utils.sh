function reload() {
  echo "Reloading .zshenv and .zshrc..."
  . ~/.zshenv
  . ~/.zshrc
  echo "Done."
}