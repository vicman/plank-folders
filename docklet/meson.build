project(
  'plank-group-docklet',
  'vala',
  version: '0.1.0',
  default_options: ['warning_level=2', 'prefix=/usr'],
)

gtk_dep = dependency('gtk+-3.0')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gee_dep = dependency('gee-0.8')
plank_dep = dependency('plank')

add_project_arguments('-DGETTEXT_PACKAGE="plank-group-docklet"', language: 'c')

shared_module(
  'docklet-app-group',
  ['AppGroupDocklet.vala', 'AppGroupItem.vala', 'AppGroupPreferences.vala'],
  dependencies: [gtk_dep, gio_dep, gio_unix_dep, gee_dep, plank_dep],
  install: true,
  install_dir: join_paths(get_option('libdir'), 'plank/docklets'),
)
