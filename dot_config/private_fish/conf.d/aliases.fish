if status is-interactive
    alias ls='eza -l'
    alias ll='eza -la'
    alias cat='bat'
    alias grep='rg'
    alias cd..='cd ..'
    alias ..='cd ..'
    alias dbox='distrobox'
    alias dboxc='distrobox create -i archlinux --init-hooks "sudo chsh -s /bin/fish $USER" --name'
    alias code='flatpak run com.vscodium.codium'
    alias createkh='set tmp_script (mktemp); curl -sSL -o "{tmp_script}" https://raw.githubusercontent.com/kube-hetzner/terraform-hcloud-kube-hetzner/master/scripts/create.sh; chmod +x "{tmp_script}"; bash "{tmp_script}"; rm "{tmp_script}"'
end
