# Grupos de aplicaciones para Plank Reloaded

[English](README.md) · [Español](README.es.md) · [Português](README.pt.md) · [Português (Brasil)](README.pt_BR.md)

Este docklet crea una carpeta de lanzadores en el dock. Cada instancia es una
categoría: por ejemplo, Desarrollo, Web o Comunicación. Al hacer clic sobre el
icono, se muestran las aplicaciones de la carpeta configurada.

![Carpetas de aplicaciones en Plank](screenshot.jpg)

La interfaz (menús, diálogos e instalador) usa el idioma del sistema:
inglés, español o portugués.

## Instalación fácil

En Debian, Ubuntu, Linux Mint y derivados:

1. Abre esta carpeta.
2. Haz doble clic en **Instalar grupos de Plank**.
3. Acepta y escribe tu contraseña cuando te la pida.

Si el icono aparece tachado, clic derecho → **Permitir iniciar**.

Desde una terminal también vale:

```bash
chmod +x install.sh
./install.sh
```

El asistente instala lo que falte, copia el docklet y puede crear tres grupos
de ejemplo (Desarrollo, Web y Comunicación) con los programas que ya tengas.

Para quitarlo: doble clic en **Quitar grupos de Plank**, o `./desinstalar.sh`.

## Cómo se organiza

Cada grupo es una carpeta que contiene copias o enlaces simbólicos a archivos
`.desktop`. No mueve ni modifica tus programas.

```text
~/Aplicaciones-dock/
├── Desarrollo/       # code.desktop, org.gnome.Terminal.desktop, …
├── Web/              # brave-browser.desktop, firefox.desktop, …
└── Comunicacion/     # telegramdesktop.desktop, discord.desktop, …
```

Los lanzadores originales suelen estar en:

- `/usr/share/applications/` (aplicaciones del sistema)
- `~/.local/share/applications/` (aplicaciones de tu usuario)

Puedes usar enlaces simbólicos para evitar copias. Ejemplo:

```bash
mkdir -p ~/Aplicaciones-dock/Desarrollo
ln -s /usr/share/applications/code.desktop ~/Aplicaciones-dock/Desarrollo/
```

## Compilar e instalar a mano

Si prefieres no usar el asistente, en Debian, Ubuntu, Mint y derivados:

```bash
sudo apt install build-essential meson valac gettext libplank-dev libgtk-3-dev libgee-0.8-dev
```

Desde esta carpeta:

```bash
meson setup --prefix=/usr build
meson compile -C build
sudo meson install -C build
```

Reinicia Plank:

```bash
killall plank
plank &
```

Después haz `Ctrl` + clic derecho en un espacio vacío del dock → **Añadir docklet** →
**Grupo de aplicaciones**.

## Configurar una categoría

Al añadirlo, Plank crea un archivo con extensión `.dockitem` dentro de
`~/.config/plank/dock1/launchers/`. Edita el bloque de preferencias y establece
la categoría y su carpeta:

```ini
[PlankDockItemPreferences]
Launcher=docklet://app-group

[PlankGroupAppGroupPreferences]
title=Desarrollo
icon=/usr/share/icons/Humanity/places/64/folder.svg
folder=~/Aplicaciones-dock/Desarrollo
```

Para añadir otras categorías, vuelve a añadir el docklet y cambia `title`,
`icon` y `folder` en su archivo `.dockitem`.

### Iconos útiles

- `applications-development`
- `web-browser`
- `internet-chat`
- `multimedia-player`
- `folder-documents`

## Límites actuales

Es un lanzador por categorías: no agrupa automáticamente las ventanas abiertas
de un mismo programa. Eso exigirá modificar el comportamiento central de Plank.
