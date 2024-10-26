# 🐧 Zorin OS Setup Script

Este repositório contém um script automatizado para configurar um ambiente de desenvolvimento completo no Zorin OS, facilitando a instalação de ferramentas essenciais para desenvolvedores e várias extensões de produtividade.

## 🎯 Objetivo

O script foi criado para inicializar um ambiente de desenvolvimento no Zorin OS rapidamente, garantindo uma configuração consistente e personalizada. Ele permite instalar Zsh, Docker, Go, NVM com Node.js, e ferramentas como VSCode, GitKraken, Postman, além de ferramentas para gerenciar as extensões para o Gnome.

## 📦 O que este script instala

- **Terminal e Shell**:
  - Zsh com Oh My Zsh, tema Powerlevel10k e fontes Nerd Fonts.

- **Ferramentas de Desenvolvimento**:
  - Docker e Docker Compose.
  - Go (opcional).
  - Python e Jupyter Notebook em contêiner Docker (opcional).
  - NVM com múltiplas versões de Node.js (opcional).
  - GitKraken (opcional).
  - VSCode com fonte JetBrains Mono configurada como padrão.
  - JetBrains Toolbox (opcional).
  - Google Chrome.
  - Postman.

- **Ferramenta de Capturas de Tela**:
  - Flameshot para capturas de tela com anotações.

## ⚙️ Pré-requisitos

Para executar este script, você precisará:
- Um sistema Zorin OS atualizado.
- Permissão de `sudo` para instalar os pacotes e realizar configurações de sistema.

## 🚀 Como Executar

1. Para baixar e executar o script automaticamente com todas as opções de instalação habilitadas, execute o comando abaixo:

   ```bash
   curl -sSL "https://raw.githubusercontent.com/ratacheski/zorin-dev-setup/main/setup.sh" | sudo bash
   ```

2. Caso deseje **ignorar** alguma instalação, você pode passar argumentos para o script. Use os argumentos abaixo conforme a necessidade:

   - `--ignore-python`: ignora a instalação de Python e do contêiner Jupyter Notebook.
   - `--ignore-golang`: ignora a instalação do Go.
   - `--ignore-nvm`: ignora a instalação do NVM e das versões do Node.js.
   - `--ignore-gitkraken`: ignora a instalação do GitKraken.
   - `--ignore-toolbox`: ignora a instalação do JetBrains Toolbox.

   ### Exemplo

   ```bash
   curl -sSL "https://raw.githubusercontent.com/ratacheski/zorin-dev-setup/main/setup.sh" | sudo bash -s -- --ignore-python --ignore-gitkraken
   ```

   No exemplo acima, o script **ignora** a instalação do **Python** e do **GitKraken**.

## 📂 Estrutura do Repositório

- `setup.sh`: O script principal de configuração.
- `docker-compose.yml`: Arquivo Docker Compose para executar o Jupyter Notebook em um contêiner, acessível na porta `8888` com persistência de dados no diretório `jupyter_notebooks`.

## 🌐 Configuração do Jupyter Notebook com Docker Compose

Se o Python e o Jupyter Notebook estiverem habilitados no script, ele irá:
1. Baixar o arquivo `docker-compose.yml` do repositório e salvá-lo em seu diretório `$HOME`.
2. Iniciar o contêiner Jupyter Notebook com o comando `docker-compose up -d`.

> **Observação**: O Jupyter Notebook estará disponível em `http://localhost:8888`. A pasta local `jupyter_notebooks` é montada no contêiner, garantindo persistência dos notebooks.
