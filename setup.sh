#!/bin/bash

# Configurações padrão
install_python="yes"
install_go="yes"
install_nvm="yes"
install_gitkraken="yes"
install_toolbox="yes"

# Parsing de argumentos
for arg in "$@"; do
  case $arg in
    --ignore-python)
      install_python="no"
      ;;
    --ignore-golang)
      install_go="no"
      ;;
    --ignore-nvm)
      install_nvm="no"
      ;;
    --ignore-gitkraken)
      install_gitkraken="no"
      ;;
    --ignore-toolbox)
      install_toolbox="no"
      ;;
    *)
      echo "Argumento desconhecido: $arg"
      exit 1
      ;;
  esac
done

# Atualiza e instala dependências necessárias
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl wget git unzip gnome-shell-extensions gnome-tweaks

# Instala o Zsh e configura o Oh My Zsh com plugins e tema
sudo apt install -y zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/plugins=(git)/plugins=(git history zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc
# Instala a fonte Nerd Font recomendada para Powerlevel10k
mkdir -p ~/.local/share/fonts
wget -P ~/.local/share/fonts https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
unzip ~/.local/share/fonts/JetBrainsMono.zip -d ~/.local/share/fonts
fc-cache -fv

# Instala Docker e Docker Compose
sudo apt install -y apt-transport-https ca-certificates gnupg lsb-release
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update && sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker $USER
newgrp docker
DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
mkdir -p $DOCKER_CONFIG/cli-plugins
curl -SL https://github.com/docker/compose/releases/download/v2.10.2/docker-compose-linux-$(uname -m) -o $DOCKER_CONFIG/cli-plugins/docker-compose
chmod +x $DOCKER_CONFIG/cli-plugins/docker-compose

# Instala Go (opcional)
if [ "$install_go" = "yes" ]; then
    GO_VERSION="1.18.3"
    wget https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
    echo "export PATH=\$PATH:/usr/local/go/bin" >> ~/.profile
fi

# Instala Python 3 e Jupyter Notebook com Docker Compose (opcional)
if [ "$install_python" = "yes" ]; then
    sudo apt install -y python3 python3-pip
    mkdir -p "$HOME/jupyter_notebooks"
    curl -o "$HOME/docker-compose.yml" https://raw.githubusercontent.com/ratacheski/zorin-dev-setup/main/docker-compose.yml
    sudo docker-compose -f "$HOME/docker-compose.yml" up -d
fi

# Instala NVM e versões do Node.js (opcional)
if [ "$install_nvm" = "yes" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
    source ~/.nvm/nvm.sh
    nvm install 8
    nvm install 12
    nvm install 16
    nvm install 18
    nvm install 20
    nvm alias default 20
fi

# Instala GitKraken (opcional)
if [ "$install_gitkraken" = "yes" ]; then
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
    sudo apt install -y ./gitkraken-amd64.deb
fi

# Instala VSCode e configura JetBrains Mono como fonte padrão
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update && sudo apt install -y code
wget -P ~/.fonts https://github.com/JetBrains/JetBrainsMono/releases/download/v2.242/JetBrainsMono-2.242.zip
unzip ~/.fonts/JetBrainsMono-2.242.zip -d ~/.fonts
fc-cache -fv
echo -e '{
  "editor.fontFamily": "JetBrains Mono"
}' > ~/.config/Code/User/settings.json

# Instala o Postman
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
sudo tar -xzf postman.tar.gz -C /opt
sudo ln -s /opt/Postman/Postman /usr/local/bin/postman

# Instala JetBrains Toolbox (opcional)
if [ "$install_toolbox" = "yes" ]; then
    wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.25.12627.tar.gz
    tar -xzf jetbrains-toolbox-1.25.12627.tar.gz
    sudo mv jetbrains-toolbox-*/jetbrains-toolbox /usr/local/bin
fi

# Instala o Google Chrome
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb

# Instala o Extension Manager para facilitar o gerenciamento de extensões Gnome
sudo apt install -y gnome-shell-extension-manager

# Instala Flameshot para capturas de tela com anotações
sudo apt install -y flameshot

# Limpeza de arquivos desnecessários
sudo apt autoremove -y && sudo apt clean
rm -rf go$GO_VERSION.linux-amd64.tar.gz postman.tar.gz gitkraken-amd64.deb jetbrains-toolbox-1.25.12627.tar.gz google-chrome-stable_current_amd64.deb

echo "Configuração concluída com sucesso! Reinicie o terminal e ative as extensões para aplicar algumas configurações."
