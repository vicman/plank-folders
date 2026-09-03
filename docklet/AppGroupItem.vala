using Gee;

namespace PlankGroup {
    public class AppGroupItem : Plank.DockletItem {
        private AppGroupPreferences preferences;

        public AppGroupItem.with_dockitem_file (GLib.File file) {
            GLib.Object (Prefs: new AppGroupPreferences.with_file (file));
        }

        construct {
            preferences = (AppGroupPreferences) Prefs;
            refresh_display ();
            preferences.notify.connect (() => { refresh_display (); });
        }

        private void refresh_display () {
            Icon = preferences.GroupIcon;
            Text = preferences.Title;
            refresh_group_icon ();
        }

        private void refresh_group_icon () {
            var base_icon = Plank.DrawingService.load_icon (preferences.GroupIcon, 128, 128);
            if (base_icon == null) return;

            var collage = base_icon.copy ();
            int icon_size = collage.get_width ();
            int mini_size = int.max (22, icon_size / 3);
            int index = 0;
            foreach (var filename in desktop_files ()) {
                if (index == 3) break;
                var app = new GLib.DesktopAppInfo.from_filename (filename);
                if (app == null || app.get_nodisplay () || app.get_icon () == null) continue;
                var icon_name = Plank.DrawingService.get_icon_from_gicon (app.get_icon ());
                if (icon_name == null) continue;
                var mini_icon = Plank.DrawingService.load_icon (icon_name, mini_size, mini_size);
                int x = (icon_size / 2) - mini_size + (index * (mini_size - 4));
                int y = icon_size - mini_size - 8;
                mini_icon.composite (collage, x, y, mini_size, mini_size, x, y,
                                     1.0, 1.0, Gdk.InterpType.BILINEAR, 255);
                index++;
            }
            ForcePixbuf = collage;
            reset_icon_buffer ();
        }

        protected override Plank.AnimationType on_clicked (Plank.PopupButton button,
                                                             Gdk.ModifierType mod,
                                                             uint32 event_time) {
            if (button == Plank.PopupButton.LEFT) {
                show_apps_menu ();
                return Plank.AnimationType.LIGHTEN;
            }
            return Plank.AnimationType.NONE;
        }

        public override bool can_accept_drop (ArrayList<string> uris) {
            foreach (var uri in uris) {
                var name = File.new_for_uri (uri).get_basename ();
                if (name != null && name.has_suffix (".desktop")) return true;
            }
            return false;
        }

        public override string get_drop_text () { return _("Add application to ") + preferences.Title; }

        public override bool accept_drop (ArrayList<string> uris) {
            if (!can_accept_drop (uris)) return false;
            var group_folder = expanded_folder ();
            var destination = File.new_for_path (group_folder);
            try { destination.make_directory_with_parents (); }
            catch (Error error) {
                if (!(error is IOError.EXISTS)) {
                    warning ("Cannot create group folder: %s", error.message);
                    return false;
                }
            }
            if (preferences.Folder == "") preferences.Folder = group_folder;

            var added = false;
            foreach (var uri in uris) {
                var source = File.new_for_uri (uri);
                var name = source.get_basename ();
                if (name == null || !name.has_suffix (".desktop")) continue;
                try {
                    source.copy (destination.get_child (name), FileCopyFlags.OVERWRITE);
                    added = true;
                } catch (Error error) {
                    warning ("Cannot add %s to group: %s", name, error.message);
                }
            }
            if (added) refresh_group_icon ();
            return added;
        }

        private string expanded_folder () {
            if (preferences.Folder.has_prefix ("~/"))
                return Path.build_filename (Environment.get_home_dir (), preferences.Folder.substring (2));
            if (preferences.Folder == "~") return Environment.get_home_dir ();
            if (preferences.Folder != "") return preferences.Folder;
            var filename = Path.get_basename (DockItemFilename).replace (".dockitem", "");
            return Path.build_filename (Environment.get_home_dir (), ".local", "share", "plank-groups", filename);
        }

        private ArrayList<string> desktop_files () {
            var results = new ArrayList<string> ();
            var folder = File.new_for_path (expanded_folder ());
            if (!folder.query_exists ()) return results;
            try {
                var entries = folder.enumerate_children (FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE,
                                                         FileQueryInfoFlags.NONE);
                FileInfo info;
                while ((info = entries.next_file ()) != null) {
                    var name = info.get_name ();
                    if ((info.get_file_type () == FileType.REGULAR || info.get_file_type () == FileType.SYMBOLIC_LINK)
                        && name.has_suffix (".desktop"))
                        results.add (Path.build_filename (expanded_folder (), name));
                }
            } catch (Error error) { warning ("Cannot read application group: %s", error.message); }
            results.sort ((a, b) => strcmp (a, b));
            return results;
        }

        private void show_apps_menu () {
            var menu = new Gtk.Menu ();
            var files = desktop_files ();
            refresh_group_icon ();
            if (files.size == 0) {
                var empty = new Gtk.MenuItem.with_label (_("No applications configured"));
                empty.set_sensitive (false);
                menu.append (empty);
            } else foreach (var filename in files) {
                var app = new GLib.DesktopAppInfo.from_filename (filename);
                if (app == null || app.get_nodisplay ()) continue;
                var item = new Gtk.ImageMenuItem.with_label (app.get_display_name ());
                if (app.get_icon () != null)
                    item.set_image (new Gtk.Image.from_gicon (app.get_icon (), Gtk.IconSize.MENU));
                item.set_always_show_image (true);
                item.activate.connect (() => {
                    try { app.launch (null, null); }
                    catch (Error error) { warning ("Cannot launch %s: %s", filename, error.message); }
                });
                menu.append (item);
            }
            var controller = get_dock ();
            if (controller != null) Plank.Helpers.popup_docklet_menu (controller, this, menu);
            else { menu.show_all (); menu.popup_at_pointer (null); }
        }

        private void show_rename_dialog () {
            var dialog = new Gtk.Dialog.with_buttons (_("Rename group"), null, Gtk.DialogFlags.MODAL,
                                                      _("Cancel"), Gtk.ResponseType.CANCEL,
                                                      _("Save"), Gtk.ResponseType.ACCEPT);
            var entry = new Gtk.Entry (); entry.text = preferences.Title; entry.activates_default = true;
            dialog.set_default_response (Gtk.ResponseType.ACCEPT);
            dialog.get_content_area ().add (entry); dialog.show_all ();
            if (dialog.run () == Gtk.ResponseType.ACCEPT && entry.text.strip () != "")
                preferences.Title = entry.text.strip ();
            dialog.destroy ();
        }

        public override ArrayList<Gtk.MenuItem> get_menu_items () {
            var items = new ArrayList<Gtk.MenuItem> ();
            var open = create_menu_item (_("Open group folder"), "folder-open", true);
            open.activate.connect (() => {
                try { AppInfo.launch_default_for_uri (File.new_for_path (expanded_folder ()).get_uri (), null); }
                catch (Error error) { warning ("Cannot open group folder: %s", error.message); }
            });
            items.add (open);
            var rename = create_menu_item (_("Rename group"), "edit-rename", true);
            rename.activate.connect (() => { show_rename_dialog (); }); items.add (rename);
            var remove = create_menu_item (_("Remove this group from the dock"), "list-remove", true);
            remove.activate.connect (() => { this.@delete (); }); items.add (remove);
            return items;
        }
    }
}
