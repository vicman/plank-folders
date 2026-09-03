# Grupos de aplicativos para o Plank Reloaded

[English](README.md) · [Español](README.es.md) · [Português](README.pt.md) · [Português (Brasil)](README.pt_BR.md)

Este docklet cria uma pasta de atalhos no dock. Cada instância é uma
categoria: por exemplo, Desenvolvimento, Web ou Comunicação. Ao clicar no
ícone, aparecem os aplicativos dessa pasta.

![Pastas de aplicativos no Plank](screenshot.jpg)

A interface (menus, diálogos e instalador) segue o idioma do sistema:
inglês, espanhol ou português.

## Instalação fácil

No Debian, Ubuntu, Linux Mint e derivados:

1. Abra esta pasta.
2. Dê um clique duplo em **Instalar grupos do Plank**.
3. Aceite e digite a senha quando for pedida.

Se o ícone aparecer riscado, clique com o botão direito → **Permitir iniciar**.

Pelo terminal:

```bash
chmod +x install.sh
./install.sh
```

O assistente instala o que faltar, copia o docklet e pode criar três grupos de
exemplo (Desenvolvimento, Web e Comunicação) com programas que você já tenha.

Para removê-lo: clique duplo em **Remover grupos do Plank**, ou `./desinstalar.sh`.

## Como se organiza

Cada grupo é uma pasta com cópias ou links simbólicos para arquivos
`.desktop`. Não move nem altera seus programas.

```text
~/Aplicaciones-dock/
├── Desarrollo/       # code.desktop, org.gnome.Terminal.desktop, …
├── Web/              # brave-browser.desktop, firefox.desktop, …
└── Comunicacion/     # telegramdesktop.desktop, discord.desktop, …
```

Os atalhos originais costumam estar em:

- `/usr/share/applications/` (aplicativos do sistema)
- `~/.local/share/applications/` (seus aplicativos)

Você pode usar links simbólicos para evitar cópias. Exemplo:

```bash
mkdir -p ~/Aplicaciones-dock/Desarrollo
ln -s /usr/share/applications/code.desktop ~/Aplicaciones-dock/Desarrollo/
```

## Compilar e instalar na mão

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

Depois use `Ctrl` + clique direito em um espaço vazio do dock → **Adicionar docklet** →
**Grupo de aplicativos**.

## Configurar uma categoria

Ao adicioná-lo, o Plank cria um arquivo `.dockitem` em
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

Para adicionar outras categorias, adicione o docklet de novo e altere `title`,
`icon` e `folder` no arquivo `.dockitem`.

### Ícones úteis

- `applications-development`
- `web-browser`
- `internet-chat`
- `multimedia-player`
- `folder-documents`

## Limites atuais

É um lançador por categorias: não agrupa automaticamente as janelas abertas do
mesmo programa. Isso exigiria alterar o comportamento central do Plank.
