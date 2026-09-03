# Plank Folders

Carpetas de aplicaciones estilo Android para [Plank Reloaded](https://github.com/zquestz/plank-reloaded).

Cada grupo es una carpeta del dock: arrastra un icono existente sobre ella para añadirlo, el icono individual se elimina del dock y la carpeta muestra miniaturas de las aplicaciones que contiene. Al hacer clic, se abre un menú centrado encima de la carpeta.

> Estado: prototipo funcional para Plank Reloaded 0.11.172 en X11. El agrupamiento mediante arrastre requiere el pequeño parche incluido para Plank.

## Funciones

- Arrastrar una aplicación ya fijada al dock sobre un grupo.
- Menú anclado sobre la carpeta, con iconos y nombres.
- Mini-iconos de las primeras tres aplicaciones sobre el icono de carpeta.
- Renombrar y eliminar grupos desde el menú contextual.
- Almacena los lanzadores dentro de `~/.local/share/plank-groups/`.
- La prueba se ejecuta aislada; no reemplaza el Plank instalado.

## Estructura

```text
docklet/                       # Plugin Application group
patches/                       # Parche para el arrastre interno de Plank
scripts/run-experimental.sh    # Lanza el prototipo de forma aislada
```

## Requisitos

Ubuntu, Mint o Debian con X11 y Plank Reloaded. Para compilar:

```bash
sudo apt install build-essential meson ninja-build valac gettext \
  libgtk-3-dev libgee-0.8-dev libbamf3-dev libwnck-3-dev \
  libgnome-menu-3-dev libcanberra-dev libdbusmenu-glib-dev \
  libdbusmenu-gtk3-dev libxi-dev libxfixes-dev
```

## Probar sin sustituir Plank

Clona Plank Reloaded y aplica el parche:

```bash
git clone https://github.com/zquestz/plank-reloaded.git plank-reloaded-android-groups
cd plank-reloaded-android-groups
git apply ../plank-folders/patches/0001-internal-app-drops.patch
meson setup build --prefix="$PWD/runtime"
meson compile -C build
```

Compila el docklet:

```bash
cd ../plank-folders/docklet
meson setup build --prefix=/usr
meson compile -C build
```

Detén temporalmente el dock habitual y ejecuta la compilación experimental:

```bash
killall plank
LD_LIBRARY_PATH="../plank-reloaded-android-groups/build/lib" \
PLANK_DOCKLET_DIRS="$PWD/build" \
../plank-reloaded-android-groups/build/src/plank -n android_group_test
```

En Preferencias → Agregados, añade **Application group**. Arrastra una aplicación ya fijada encima de esa carpeta. Pulsa `Ctrl+C` para cerrar la prueba y ejecuta `plank &` para volver al Plank normal.

## Licencia

El docklet se distribuye bajo GPL-3.0-or-later. El parche se aplica a Plank Reloaded, que mantiene sus propias licencias GPL-3.0 y LGPL-2.1.
