function update --wraps=dnf --description 'alias update=sudo dnf up --refresh && flatpak update'
  sudo dnf up --refresh && flatpak update
        
end
