project(
  'plank-group-docklet',
  'vala',
  version: '0.1.0',
  default_options: ['warning_level=2', 'prefix=/usr'],
)

i18n = import('i18n')

gtk_dep = dependency('gtk+-3.0')
gio_dep = dependency('gio-2.0')
gio_unix_dep = dependency('gio-unix-2.0')
gee_dep = dependency('gee-0.8')
plank_dep = dependency('plank')

gettext_package = meson.project_name()
localedir = join_paths(get_option('prefix'), get_option('localedir'))

add_project_arguments(
  '-DGETTEXT_PACKAGE="' + gettext_package + '"',
  language: 'c',
)

conf = configuration_data()
conf.set('GETTEXT_PACKAGE', gettext_package)
conf.set('LOCALEDIR', localedir)
config_vala = configure_file(
  input: 'config.vala.in',
  output: 'config.vala',
  configuration: conf,
)

subdir('po')

shared_module(
  'docklet-app-group',
  [
    config_vala,
    'i18n.vala',
    'AppGroupDocklet.vala',
    'AppGroupItem.vala',
    'AppGroupPreferences.vala',
  ],
  dependencies: [gtk_dep, gio_dep, gio_unix_dep, gee_dep, plank_dep],
  install: true,
  install_dir: join_paths(get_option('libdir'), 'plank/docklets'),
)
