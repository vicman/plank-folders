# Grupos de aplicações para o Plank Reloaded

[English](README.md) · [Español](README.es.md) · [Português](README.pt.md) · [Português (Brasil)](README.pt_BR.md)

Este docklet cria uma pasta de lançadores na dock. Cada instância é uma
categoria: por exemplo, Desenvolvimento, Web ou Comunicação. Ao clicar no
ícone, aparecem as aplicações dessa pasta.

![Pastas de aplicações no Plank](screenshot.jpg)

A interface (menus, diálogos e instalador) segue o idioma do sistema:
inglês, espanhol ou português.

## Instalação fácil

No Debian, Ubuntu, Linux Mint e derivados:

1. Abra esta pasta.
2. Faça duplo clique em **Instalar grupos do Plank**.
3. Aceite e introduza a palavra-passe quando for pedida.

Se o ícone aparecer riscado, clique direito → **Permitir iniciar**.

A partir de um terminal:

```bash
chmod +x install.sh
./install.sh
```

O assistente instala o que faltar, copia o docklet e pode criar três grupos de
exemplo (Desenvolvimento, Web e Comunicação) com programas que já tenha.

Para o remover: duplo clique em **Remover grupos do Plank**, ou `./desinstalar.sh`.

## Como se organiza

Cada grupo é uma pasta com cópias ou ligações simbólicas para ficheiros
`.desktop`. Não move nem altera os seus programas.

```text
~/Aplicaciones-dock/
├── Desarrollo/       # code.desktop, org.gnome.Terminal.desktop, …
├── Web/              # brave-browser.desktop, firefox.desktop, …
└── Comunicacion/     # telegramdesktop.desktop, discord.desktop, …
```

Os lançadores originais estão normalmente em:

- `/usr/share/applications/` (aplicações do sistema)
- `~/.local/share/applications/` (as suas aplicações)

Pode usar ligações simbólicas para evitar cópias. Exemplo:

```bash
mkdir -p ~/Aplicaciones-dock/Desarrollo
ln -s /usr/share/applications/code.desktop ~/Aplicaciones-dock/Desarrollo/
```

## Compilar e instalar à mão

Se preferir não usar o assistente, no Debian, Ubuntu, Mint e derivados:

```bash
sudo apt install build-essential meson valac gettext libplank-dev libgtk-3-dev libgee-0.8-dev
```

Nesta pasta:

```bash
meson setup --prefix=/usr build
meson compile -C build
sudo meson install -C build
```

Reinicie o Plank:

```bash
killall plank
plank &
```

Depois faça `Ctrl` + clique direito num espaço vazio da dock → **Adicionar docklet** →
**Grupo de aplicações**.

## Configurar uma categoria

Ao adicioná-lo, o Plank cria um ficheiro `.dockitem` em
`~/.config/plank/dock1/launchers/`. Edite o bloco de preferências e defina o
nome e a pasta:

```ini
[PlankDockItemPreferences]
Launcher=docklet://app-group

[PlankGroupAppGroupPreferences]
title=Desenvolvimento
icon=/usr/share/icons/Humanity/places/64/folder.svg
folder=~/Aplicaciones-dock/Desarrollo
```

Para adicionar outras categorias, volte a adicionar o docklet e altere `title`,
`icon` e `folder` no respectivo ficheiro `.dockitem`.

### Ícones úteis

- `applications-development`
- `web-browser`
- `internet-chat`
- `multimedia-player`
- `folder-documents`

## Limites atuais

É um lançador por categorias: não agrupa automaticamente as janelas abertas do
mesmo programa. Isso exigiria alterar o comportamento central do Plank.
