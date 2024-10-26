#!/bin/bash

# Configurações padrão
install_python="yes"
install_go="yes"
install_nvm="yes"
install_gitkraken="yes"
install_toolbox="yes"

# Parsing de argumentos
if [ "$#" -gt 0 ]; then
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
fi

# Verifica se o script foi iniciado como root
if [ "$EUID" -eq 0 ]; then
  echo "Por favor, execute este script como usuário normal, sem sudo."
  exit 1
fi

# Exibe as configurações selecionadas
echo "=== RESUMO DA INSTALAÇÃO ==="
echo "Python e Jupyter Notebook: $( [ "$install_python" = "yes" ] && echo "SERÁ instalado" || echo "NÃO será instalado" )"
echo "Go: $( [ "$install_go" = "yes" ] && echo "SERÁ instalado" || echo "NÃO será instalado" )"
echo "NVM com Node.js: $( [ "$install_nvm" = "yes" ] && echo "SERÁ instalado" || echo "NÃO será instalado" )"
echo "GitKraken: $( [ "$install_gitkraken" = "yes" ] && echo "SERÁ instalado" || echo "NÃO será instalado" )"
echo "JetBrains Toolbox: $( [ "$install_toolbox" = "yes" ] && echo "SERÁ instalado" || echo "NÃO será instalado" )"
echo "============================"

# Pausa para o usuário revisar
read -rp "Pressione Enter para continuar com essas configurações ou Ctrl+C para cancelar." user_input


echo "=== CRIANDO BACKUP DO AMBIENTE ==="
# Instala Timeshift e cria um ponto de restauração inicial com sudo
sudo apt update && sudo apt install -y timeshift
sudo timeshift --create --comments "Ponto de restauração inicial antes de configurações"

echo "=== ATUALIZANDO E INSTALANDO DEPENDÊNCIAS NECESSÁRIAS ==="
# Atualiza e instala dependências necessárias com sudo
sudo apt install -y curl wget git unzip gnome-shell-extensions gnome-tweaks


echo "=== INSTALANDO ZSH E CONFIGURANDO OH MY ZSH COM PLUGINS E TEMA ==="
# Instala o Zsh e configura o Oh My Zsh com plugins e tema
sudo apt install -y zsh
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i 's/plugins=(git)/plugins=(git history zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc

echo "=== VERIFICANDO INSTALAÇÃO DA FONTE JETBRAINS MONO ==="
# Instala a fonte Nerd Font recomendada para Powerlevel10k, se ainda não estiver instalada
FONT_DIR="$HOME/.local/share/fonts"
if fc-list | grep -qi "JetBrainsMono"; then
  echo "A fonte JetBrains Mono já está instalada. Pulando download."
else
  echo "Instalando a fonte JetBrains Mono..."
  mkdir -p "$FONT_DIR"
  wget -P "$FONT_DIR" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/JetBrainsMono.zip
  unzip "$FONT_DIR/JetBrainsMono.zip" -d "$FONT_DIR"
  fc-cache -fv
  echo "Fonte JetBrains Mono instalada com sucesso."
fi

echo "=== INSTALANDO DO DOCKER ==="
# Instala Docker e Docker Compose com sudo
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
    echo "=== INSTALANDO O GOLANG $GO_VERSION ==="
    wget https://golang.org/dl/go$GO_VERSION.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz
    echo "export PATH=\$PATH:/usr/local/go/bin" >> "$HOME/.profile"
else
    echo "=== PULANDO INSTALAÇÃO DO GOLANG ==="
fi

# Instala Python 3 e Jupyter Notebook com Docker Compose (opcional)
if [ "$install_python" = "yes" ]; then

    echo "=== INSTALANDO O PYTHON 3 ==="
    sudo apt install -y python3 python3-pip

    echo "=== CONFIGURANDO AMBIENTE JUPYTER NOTEBOOK COM DOCKER COMPOSE ==="    
    # Cria uma pasta específica para o ambiente Jupyter Notebook
    JUPYTER_DIR="$HOME/jupyter_environment"
    mkdir -p "$JUPYTER_DIR/notebooks"
    
    # Baixa o arquivo docker-compose.yml do GitHub para o diretório do Jupyter
    curl -o "$JUPYTER_DIR/docker-compose.yml" https://raw.githubusercontent.com/SEU_USUARIO/zorin-setup-script/main/docker-compose.yml

    # Inicializa o contêiner Jupyter Notebook com Docker Compose
    (cd "$JUPYTER_DIR" && docker-compose up -d)
else
    echo "=== PULANDO INSTALAÇÃO DO PYTHON ==="
fi

# Instala NVM e versões do Node.js (opcional)
if [ "$install_nvm" = "yes" ]; then
    echo "=== INSTALANDO O NVM ==="
    sh -c "curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash"
    source "$HOME/.nvm/nvm.sh"
    nvm install 8
    nvm install 12
    nvm install 16
    nvm install 18
    nvm install 20
    nvm alias default 20
else
    echo "=== PULANDO INSTALAÇÃO DO NVM ==="
fi

# Instala GitKraken (opcional)
if [ "$install_gitkraken" = "yes" ]; then
    echo "=== INSTALANDO O GITKRAKEN ==="
    wget https://release.gitkraken.com/linux/gitkraken-amd64.deb
    sudo apt install -y ./gitkraken-amd64.deb
else
    echo "=== PULANDO INSTALAÇÃO DO GITKRAKEN ==="
fi

# Instala VSCode e configura JetBrains Mono como fonte padrão
echo "=== INSTALANDO O VSCODE ==="
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" | sudo tee /etc/apt/sources.list.d/vscode.list
sudo apt update && sudo apt install -y code
echo -e '{
  "editor.fontFamily": "JetBrains Mono"
}' > "$HOME/.config/Code/User/settings.json"

# Instala o Postman
echo "=== INSTALANDO O POSTMAN ==="
wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
sudo tar -xzf postman.tar.gz -C /opt
sudo ln -s /opt/Postman/Postman /usr/local/bin/postman

# Instala JetBrains Toolbox (opcional)
if [ "$install_toolbox" = "yes" ]; then
    echo "=== INSTALANDO O JETBRAINS TOOLBOX ==="
    wget https://download.jetbrains.com/toolbox/jetbrains-toolbox-2.5.1.34629.tar.gz
    tar -xzf jetbrains-toolbox-2.5.1.34629.tar.gz
    sudo mv jetbrains-toolbox-*/jetbrains-toolbox /usr/local/bin
else
    echo "=== PULANDO INSTALAÇÃO DO JETBRAINS TOOLBOX ==="
fi

# Instala o Google Chrome
echo "=== INSTALANDO O CHROME ==="
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install -y ./google-chrome-stable_current_amd64.deb

# Instala o Extension Manager para facilitar o gerenciamento de extensões Gnome
echo "=== INSTALANDO O GNOME EXTENSION E EXTENSÕES ADICIONAIS ==="
sudo apt install -y gnome-shell-extension-manager
# Baixa e instala manualmente extensões do Gnome
EXTENSIONS_DIR="$HOME/.local/share/gnome-shell/extensions"
mkdir -p "$EXTENSIONS_DIR"
git clone https://github.com/micheleg/dash-to-dock.git "$EXTENSIONS_DIR/dash-to-dock@micxgx.gmail.com"
gnome-extensions enable dash-to-dock@micxgx.gmail.com
git clone https://github.com/hackeita/pano.git "$EXTENSIONS_DIR/pano@hackeriet.no"
gnome-extensions enable pano@hackeriet.no

# Instala Flameshot para capturas de tela com anotações
echo "=== INSTALANDO O FLAMESHOT ==="
sudo apt install -y flameshot

# Limpeza de arquivos desnecessários
echo "=== LIMPEZA DE ARQUIVOS FINAIS ==="
sudo apt autoremove -y && sudo apt clean
rm -rf go$GO_VERSION.linux-amd64.tar.gz postman.tar.gz gitkraken-amd64.deb jetbrains-toolbox-2.5.1.34629.tar.gz google-chrome-stable_current_amd64.deb

# Comando para alterar o shell para Zsh (movido para o final)
echo "Para definir o Zsh como seu shell padrão, será necessário inserir sua senha."
chsh -s $(which zsh)

# Exibe mensagem final
echo "Configuração concluída com sucesso!"
echo "Reinicie o terminal e ative as extensões para aplicar algumas configurações."
