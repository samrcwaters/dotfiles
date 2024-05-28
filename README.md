# Prerequisites
- Zsh
- Oh-My-Zsh
- Neovim
- ripgrep
- fd
- jq
- nvm
- Terraform

# Setup
1. `git clone git@github.com:samrcwaters/dotfiles.git ~/dotfiles`
2. `cd ~/dotfiles`
3. `./bin/dotfiles_setup/link.sh`
4. If you need workstation-specific environment variables which may contain sensitive information, place them in `~/.zshenv`, and do not commit that file
    - Eg, `export DOTFILES_PROFILE=pg`

# Utility Scripts
## ./bin/dotfiles_setup/link.sh
- Create symlinks between your home directory and this directory

## ./bin/dotfiles_setup/backup.sh
- Back up any files in your home directory which link.sh will try to create symlinks for

## ./bin/dotfiles_setup/clean_backups.sh
- Delete any existing backups

# Future Work
- Automate installation of prerequisite tools