using Gee;

namespace PlankGroup {
    public class AppGroupItem : Plank.DockletItem {
        private AppGroupPreferences preferences;
        private bool watching_drags = false;
        private bool drop_armed = false;
        private Plank.DockItem? drop_source = null;
        private uint drop_poll_id = 0;

        public AppGroupItem.with_dockitem_file (GLib.File file) {
            GLib.Object (Prefs: new AppGroupPreferences.with_file (file));
        }

        construct {
            preferences = (AppGroupPreferences) Prefs;
            refresh_display ();

            preferences.notify.connect (() => {
                refresh_display ();
            });
            notify["Container"].connect (ensure_drag_watch);
            Idle.add (() => {
                ensure_drag_watch ();
                return false;
            });
        }

        private void drop_log (string message) {
            try {
                var file = File.new_for_path ("/tmp/plank-group-drop.log");
                var stream = file.append_to (FileCreateFlags.NONE);
                var now = new DateTime.now_local ().format ("%H:%M:%S");
                stream.write ("%s %s %s\n".printf (now, preferences.Title, message).data);
                stream.close ();
            } catch (Error e) {
                warning ("app-group: %s", message);
            }
        }

        private void ensure_drag_watch () {
            if (watching_drags)
                return;
            var dock = get_dock ();
            if (dock == null)
                return;
            watching_drags = true;
            drop_log ("watch connected");
            dock.drag_manager.notify["InternalDragActive"].connect (on_internal_drag_changed);
            dock.window.notify["HoveredItem"].connect (on_hovered_item_changed);
            dock.window.drag_end.connect (on_window_drag_end);
        }

        protected override Plank.AnimationType on_hovered () {
            ensure_drag_watch ();
            var dock = get_dock ();
            if (dock != null && dock.drag_manager.InternalDragActive) {
                var dragged = dock.drag_manager.DragItem;
                if (dragged != null && dragged != this) {
                    drop_armed = true;
                    drop_source = dragged;
                    start_drop_poll ();
                    drop_log ("hover-arm launcher=%s".printf (dragged.Launcher ?? "(null)"));
                }
            }
            return Plank.AnimationType.NONE;
        }

        private void on_hovered_item_changed () {
            update_drop_arm ();
        }

        private bool pointer_over_item (Plank.DockController dock, Plank.DockItem item) {
            Gdk.Rectangle rect = dock.position_manager.get_hover_region_for_element (item);
            int px, py, ox = 0, oy = 0;
            var seat = dock.window.get_display ().get_default_seat ();
            seat.get_pointer ().get_position (null, out px, out py);
            var win = dock.window.get_window ();
            if (win != null)
                win.get_origin (out ox, out oy);
            int x = px - ox;
            int y = py - oy;
            return x >= rect.x && x < rect.x + rect.width && y >= rect.y && y < rect.y + rect.height;
        }

        private void update_drop_arm () {
            var dock = get_dock ();
            if (dock == null || !dock.drag_manager.InternalDragActive)
                return;

            var dragged = dock.drag_manager.DragItem;
            if (dragged == null || dragged == this)
                return;

            var hovered = dock.window.HoveredItem;
            bool over_folder = (hovered == this) || pointer_over_item (dock, this);
            bool over_dragged = (hovered == null || hovered == dragged) || pointer_over_item (dock, dragged);

            if (over_folder) {
                drop_armed = true;
                drop_source = dragged;
                start_drop_poll ();
                drop_log ("arm hovered=%s".printf (hovered != null ? hovered.Text : "null"));
            } else if (drop_armed && over_dragged) {
                // Keep target after Plank swaps the dragged icon into this slot.
            } else if (hovered != null && hovered != this && hovered != dragged) {
                drop_armed = false;
                drop_source = null;
            }
        }

        private void start_drop_poll () {
            if (drop_poll_id != 0)
                return;
            drop_poll_id = Timeout.add (40, () => {
                var dock = get_dock ();
                if (dock != null && dock.drag_manager.InternalDragActive) {
                    update_drop_arm ();
                    return true;
                }
                drop_poll_id = 0;
                finish_internal_drop ("poll");
                return false;
            });
        }

        private void on_internal_drag_changed () {
            var dock = get_dock ();
            if (dock == null)
                return;
            if (dock.drag_manager.InternalDragActive) {
                drop_armed = false;
                drop_source = null;
                start_drop_poll ();
                drop_log ("drag-begin");
                return;
            }
        }

        private void on_window_drag_end () {
            if (drop_poll_id != 0) {
                Source.remove (drop_poll_id);
                drop_poll_id = 0;
            }
            finish_internal_drop ("drag-end");
        }

        private void finish_internal_drop (string why) {
            var source = drop_source;
            var armed = drop_armed;
            drop_armed = false;
            drop_source = null;
            drop_log ("%s armed=%s launcher=%s".printf (
                why, armed.to_string (), source != null ? source.Launcher : "(none)"));
            if (!armed || source == null || source == this)
                return;

            var launcher = source.Launcher;
            if (launcher == null || launcher == "")
                return;

            Idle.add (() => {
                move_launcher_into_group (source, launcher);
                return false;
            });
        }

        private void move_launcher_into_group (Plank.DockItem source, string launcher) {
            drop_log ("move %s accept=%s".printf (launcher, can_accept_drop (uris_of (launcher)).to_string ()));
            var uris = uris_of (launcher);
            if (!can_accept_drop (uris) || !accept_drop (uris)) {
                drop_log ("accept_drop failed for %s".printf (launcher));
                return;
            }
            drop_log ("added %s".printf (launcher));

            if (!source.can_be_removed ())
                return;

            unowned Plank.ApplicationDockItem? app_item = (source as Plank.ApplicationDockItem);
            if (app_item == null || !(app_item.is_running () || app_item.has_unity_info ())) {
                source.IsVisible = false;
                if (source.Container != null)
                    source.Container.remove (source);
            }
            source.@delete ();
        }

        private ArrayList<string> uris_of (string launcher) {
            var uris = new ArrayList<string> ();
            uris.add (launcher);
            return uris;
        }

        private void refresh_display () {
            Icon = preferences.GroupIcon;
            Text = preferences.Title;
            refresh_group_icon ();
        }

        // Draw a small collage of the first applications over the folder.
        // This keeps the group recognizable even before it is opened.
        private void refresh_group_icon () {
            var base_icon = Plank.DrawingService.load_icon (preferences.GroupIcon, 128, 128);
            if (base_icon == null)
                return;

            var collage = base_icon.copy ();
            var files = desktop_files ();
            int icon_size = collage.get_width ();
            int mini_size = int.max (22, icon_size / 3);
            int index = 0;

            foreach (var filename in files) {
                if (index == 3)
                    break;

                var app = new GLib.DesktopAppInfo.from_filename (filename);
                if (app == null || app.get_icon () == null)
                    continue;

                var icon_name = Plank.DrawingService.get_icon_from_gicon (app.get_icon ());
                if (icon_name == null)
                    continue;

                var mini_icon = Plank.DrawingService.load_icon (icon_name, mini_size, mini_size);
                int x = (icon_size / 2) - mini_size + (index * (mini_size - 4));
                int y = icon_size - mini_size - 8;
                mini_icon.composite (collage, x, y, mini_size, mini_size,
                                     x, y, 1.0, 1.0,
                                     Gdk.InterpType.BILINEAR, 255);
                index++;
            }

            ForcePixbuf = collage;
            reset_icon_buffer ();
        }

        protected override Plank.AnimationType on_clicked (
            Plank.PopupButton button,
            Gdk.ModifierType mod,
            uint32 event_time
        ) {
            if (button == Plank.PopupButton.LEFT) {
                show_apps_menu ();
                return Plank.AnimationType.LIGHTEN;
            }
            return Plank.AnimationType.NONE;
        }

        public override bool can_accept_drop (ArrayList<string> uris) {
            foreach (var uri in uris) {
                if (desktop_path_from_uri (uri) != null)
                    return true;
            }
            return false;
        }

        public override string get_drop_text () {
            return _("Add application to %s").printf (preferences.Title);
        }

        public override bool accept_drop (ArrayList<string> uris) {
            if (!can_accept_drop (uris))
                return false;

            var group_folder = expanded_folder ();
            var destination = File.new_for_path (group_folder);
            try {
                destination.make_directory_with_parents ();
            } catch (Error error) {
                // The directory already exists, which is the normal case.
                if (!(error is IOError.EXISTS)) {
                    warning ("Cannot create group folder: %s", error.message);
                    return false;
                }
            }

            // On the first drop, persist the automatically chosen folder so
            // renaming the visual group later never loses its applications.
            if (preferences.Folder == "")
                preferences.Folder = group_folder;

            var added = false;
            foreach (var uri in uris) {
                var path = desktop_path_from_uri (uri);
                if (path == null)
                    continue;
                path = visible_desktop_path (path);

                var source = File.new_for_path (path);
                var name = source.get_basename ();
                if (name == null || !name.has_suffix (".desktop"))
                    continue;

                var dest = destination.get_child (name);
                try {
                    if (dest.query_exists ())
                        dest.delete ();
                    dest.make_symbolic_link (path);
                    added = true;
                } catch (Error link_error) {
                    try {
                        source.copy (dest, FileCopyFlags.OVERWRITE);
                        added = true;
                    } catch (Error error) {
                        warning ("Cannot add %s to group: %s", name, error.message);
                    }
                }
            }
            if (added)
                refresh_group_icon ();
            return added;
        }

        private string? desktop_path_from_uri (string uri) {
            if (uri.has_prefix ("application://")) {
                var app = new DesktopAppInfo (uri.substring ("application://".length));
                return app != null ? app.get_filename () : null;
            }

            var source = File.new_for_uri (uri);
            var name = source.get_basename ();
            if (name == null)
                return null;

            if (name.has_suffix (".desktop"))
                return source.get_path ();

            if (!name.has_suffix (".dockitem"))
                return null;

            try {
                var key = new KeyFile ();
                key.load_from_file (source.get_path (), KeyFileFlags.NONE);
                var launcher = key.get_string ("PlankDockItemPreferences", "Launcher");
                if (launcher != null && launcher != uri)
                    return desktop_path_from_uri (launcher);
            } catch (Error error) {
                warning ("Cannot read dropped dock item: %s", error.message);
            }
            return null;
        }

        private string visible_desktop_path (string path) {
            var app = new DesktopAppInfo.from_filename (path);
            if (app != null && !app.get_nodisplay ())
                return path;

            var name = Path.get_basename (path);
            if (name.has_suffix ("-url-handler.desktop")) {
                var alt = replace_basename (path, name.replace ("-url-handler.desktop", ".desktop"));
                if (alt != null)
                    return alt;
            }

            string[] dirs = {
                Path.build_filename (Environment.get_home_dir (), ".local", "share", "applications"),
                "/usr/share/applications",
                "/usr/local/share/applications"
            };
            if (app != null) {
                var id = app.get_id ();
                if (id != null && id.has_suffix ("-url-handler.desktop")) {
                    var alt_id = id.replace ("-url-handler.desktop", ".desktop");
                    foreach (var dir in dirs) {
                        var candidate = Path.build_filename (dir, alt_id);
                        if (FileUtils.test (candidate, FileTest.EXISTS))
                            return candidate;
                    }
                }
            }
            return path;
        }

        private string? replace_basename (string path, string new_name) {
            var dir = Path.get_dirname (path);
            var candidate = Path.build_filename (dir, new_name);
            if (FileUtils.test (candidate, FileTest.EXISTS))
                return candidate;
            candidate = Path.build_filename ("/usr/share/applications", new_name);
            if (FileUtils.test (candidate, FileTest.EXISTS))
                return candidate;
            candidate = Path.build_filename (Environment.get_home_dir (), ".local", "share", "applications", new_name);
            if (FileUtils.test (candidate, FileTest.EXISTS))
                return candidate;
            return null;
        }

        private string expanded_folder () {
            if (preferences.Folder.has_prefix ("~/"))
                return Path.build_filename (Environment.get_home_dir (), preferences.Folder.substring (2));
            if (preferences.Folder == "~")
                return Environment.get_home_dir ();
            if (preferences.Folder != "")
                return preferences.Folder;

            var filename = Path.get_basename (DockItemFilename).replace (".dockitem", "");
            return Path.build_filename (Environment.get_home_dir (), ".local", "share",
                                        "plank-groups", filename);
        }

        private void show_rename_dialog () {
            var dialog = new Gtk.Dialog.with_buttons (
                _("Rename group"), null, Gtk.DialogFlags.MODAL,
                _("Cancel"), Gtk.ResponseType.CANCEL,
                _("Save"), Gtk.ResponseType.ACCEPT
            );
            var entry = new Gtk.Entry ();
            entry.text = preferences.Title;
            entry.activates_default = true;
            dialog.set_default_response (Gtk.ResponseType.ACCEPT);
            dialog.get_content_area ().add (entry);
            dialog.show_all ();

            if (dialog.run () == Gtk.ResponseType.ACCEPT && entry.text.strip () != "")
                preferences.Title = entry.text.strip ();
            dialog.destroy ();
        }

        private Gdk.Pixbuf? pixbuf_for_icon (string name, int size) {
            if (name == null || name.strip () == "")
                return null;

            var expanded = name;
            if (name.has_prefix ("~/"))
                expanded = Path.build_filename (Environment.get_home_dir (), name.substring (2));

            if (FileUtils.test (expanded, FileTest.IS_REGULAR)) {
                try {
                    return new Gdk.Pixbuf.from_file_at_size (expanded, size, size);
                } catch (Error file_error) {
                }
            }

            try {
                return Gtk.IconTheme.get_default ().load_icon (name, size, Gtk.IconLookupFlags.FORCE_SIZE);
            } catch (Error theme_error) {
                return Plank.DrawingService.load_icon (name, size, size);
            }
        }

        private string? combo_icon_name (Gtk.ComboBox combo, Gtk.ListStore store) {
            Gtk.TreeIter iter;
            if (!combo.get_active_iter (out iter))
                return null;
            string icon_name;
            store.get (iter, 2, out icon_name);
            return icon_name;
        }

        private void set_icon_preview (Gtk.Image preview, string? name) {
            var pix = pixbuf_for_icon (name ?? "folder", 64);
            if (pix != null)
                preview.set_from_pixbuf (pix);
            else
                preview.set_from_icon_name ("image-missing", Gtk.IconSize.DIALOG);
        }

        private void show_icon_dialog () {
            var dialog = new Gtk.Dialog.with_buttons (
                _("Change icon of %s").printf (preferences.Title),
                null, Gtk.DialogFlags.MODAL,
                _("Cancel"), Gtk.ResponseType.CANCEL,
                _("Save"), Gtk.ResponseType.ACCEPT
            );
            dialog.set_default_size (460, 180);
            dialog.set_default_response (Gtk.ResponseType.ACCEPT);

            var content = dialog.get_content_area ();
            content.set_spacing (8);
            content.set_margin_start (12);
            content.set_margin_end (12);
            content.set_margin_top (8);
            content.set_margin_bottom (8);

            var row = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 12);
            var preview = new Gtk.Image ();
            preview.set_pixel_size (64);
            row.pack_start (preview, false, false, 0);

            var fields = new Gtk.Box (Gtk.Orientation.VERTICAL, 6);
            fields.pack_start (new Gtk.Label (_("Theme icon or file:")) { xalign = 0.0f }, false, false, 0);

            string[] ids = {
                "folder",
                "applications-other",
                "applications-development",
                "web-browser",
                "internet-chat",
                "multimedia-player",
                "folder-documents",
                "applications-games",
                "applications-graphics",
                "applications-office",
                "applications-system",
                "preferences-desktop"
            };
            string[] labels = {
                _("Folder"),
                _("Applications"),
                _("Development"),
                _("Browser"),
                _("Chat"),
                _("Multimedia"),
                _("Documents"),
                _("Games"),
                _("Graphics"),
                _("Office"),
                _("System"),
                _("Preferences")
            };

            var store = new Gtk.ListStore (3, typeof (Gdk.Pixbuf), typeof (string), typeof (string));
            var current = preferences.GroupIcon;
            var active = 0;
            var found = false;
            for (var i = 0; i < ids.length; i++) {
                Gtk.TreeIter iter;
                store.append (out iter);
                var pix = pixbuf_for_icon (ids[i], 24);
                store.set (iter, 0, pix, 1, labels[i], 2, ids[i]);
                if (ids[i] == current) {
                    active = i;
                    found = true;
                }
            }
            if (!found && current != "") {
                Gtk.TreeIter iter;
                store.append (out iter);
                var pix = pixbuf_for_icon (current, 24);
                store.set (iter, 0, pix, 1, Path.get_basename (current), 2, current);
                active = ids.length;
            }

            var combo = new Gtk.ComboBox.with_model (store);
            var pix_cell = new Gtk.CellRendererPixbuf ();
            var text_cell = new Gtk.CellRendererText ();
            combo.pack_start (pix_cell, false);
            combo.pack_start (text_cell, true);
            combo.add_attribute (pix_cell, "pixbuf", 0);
            combo.add_attribute (text_cell, "text", 1);
            combo.hexpand = true;

            fields.pack_start (combo, false, false, 0);

            var browse = new Gtk.Button.with_label (_("Choose file…"));
            browse.set_halign (Gtk.Align.START);
            fields.pack_start (browse, false, false, 0);

            row.pack_start (fields, true, true, 0);
            content.add (row);

            combo.changed.connect (() => {
                set_icon_preview (preview, combo_icon_name (combo, store));
            });
            combo.set_active (active);

            browse.clicked.connect (() => {
                var chooser = new Gtk.FileChooserDialog (
                    _("Choose icon"), dialog, Gtk.FileChooserAction.OPEN,
                    _("Cancel"), Gtk.ResponseType.CANCEL,
                    _("Use"), Gtk.ResponseType.ACCEPT
                );
                var filter = new Gtk.FileFilter ();
                filter.set_filter_name (_("Images"));
                filter.add_pixbuf_formats ();
                chooser.add_filter (filter);
                if (FileUtils.test ("/usr/share/icons", FileTest.IS_DIR))
                    chooser.set_current_folder ("/usr/share/icons");

                if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                    var filename = chooser.get_filename ();
                    if (filename != null) {
                        Gtk.TreeIter iter;
                        store.append (out iter);
                        store.set (iter, 0, pixbuf_for_icon (filename, 24),
                                   1, Path.get_basename (filename), 2, filename);
                        combo.set_active_iter (iter);
                    }
                }
                chooser.destroy ();
            });

            dialog.show_all ();
            if (dialog.run () == Gtk.ResponseType.ACCEPT) {
                var value = combo_icon_name (combo, store);
                if (value != null && value != "") {
                    preferences.GroupIcon = value;
                    refresh_display ();
                }
            }
            dialog.destroy ();
        }

        private void remove_app_from_group (string filename) {
            try {
                var file = File.new_for_path (filename);
                if (file.query_exists ())
                    file.delete ();
            } catch (Error error) {
                warning ("Cannot remove %s from group: %s", filename, error.message);
            }
            refresh_group_icon ();
        }

        private ArrayList<string> desktop_files () {
            var results = new ArrayList<string> ();
            var folder = File.new_for_path (expanded_folder ());

            if (!folder.query_exists ())
                return results;

            try {
                var entries = folder.enumerate_children (
                    FileAttribute.STANDARD_NAME + "," + FileAttribute.STANDARD_TYPE,
                    FileQueryInfoFlags.NONE
                );
                FileInfo info;
                while ((info = entries.next_file ()) != null) {
                    var name = info.get_name ();
                    if ((info.get_file_type () == FileType.REGULAR ||
                         info.get_file_type () == FileType.SYMBOLIC_LINK) &&
                        name.has_suffix (".desktop"))
                        results.add (Path.build_filename (expanded_folder (), name));
                }
            } catch (Error error) {
                warning ("Cannot read application group: %s", error.message);
            }

            results.sort ((a, b) => strcmp (a, b));
            return results;
        }

        private bool pointer_over_widget (Gtk.Widget area, Gtk.Widget target) {
            int px, py;
            area.get_pointer (out px, out py);
            Gtk.Allocation area_alloc;
            area.get_allocation (out area_alloc);

            int tx, ty;
            if (target.translate_coordinates (area, 0, 0, out tx, out ty)) {
                Gtk.Allocation alloc;
                target.get_allocation (out alloc);
                int pad = 10;
                if (px >= tx - pad && px < tx + alloc.width + pad
                    && py >= ty - pad && py < ty + alloc.height + pad)
                    return true;
            }

            return px >= area_alloc.width - 36;
        }

        private Gtk.MenuItem create_app_row (string filename, GLib.DesktopAppInfo app) {
            var item = new Gtk.MenuItem ();
            var box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 8);

            var app_icon = app.get_icon ();
            if (app_icon != null)
                box.pack_start (new Gtk.Image.from_gicon (app_icon, Gtk.IconSize.MENU), false, false, 0);

            var label = new Gtk.Label (app.get_display_name ());
            label.set_xalign (0.0f);
            label.set_ellipsize (Pango.EllipsizeMode.END);
            label.set_hexpand (true);
            box.pack_start (label, true, true, 0);

            var remove_icon = new Gtk.Image.from_icon_name ("list-remove", Gtk.IconSize.MENU);
            remove_icon.set_tooltip_text (_("Remove from group"));
            box.pack_end (remove_icon, false, false, 0);

            item.add (box);
            item.set_tooltip_text (_("Click to open. The − icon removes the application from the group."));

            var file_to_remove = filename;
            var app_to_launch = app;
            item.activate.connect (() => {
                if (pointer_over_widget (item, remove_icon)) {
                    drop_log ("remove %s".printf (file_to_remove));
                    remove_app_from_group (file_to_remove);
                    return;
                }
                try {
                    app_to_launch.launch (null, null);
                } catch (Error error) {
                    warning ("Cannot launch %s: %s", filename, error.message);
                }
            });
            return item;
        }

        private void show_apps_menu () {
            var menu = new Gtk.Menu ();
            var files = desktop_files ();
            if (preferences.Folder == "" && files.size > 0)
                preferences.Folder = expanded_folder ();
            refresh_group_icon ();

            var added = 0;
            foreach (var filename in files) {
                var app = new GLib.DesktopAppInfo.from_filename (filename);
                if (app == null)
                    continue;
                menu.append (create_app_row (filename, app));
                added++;
            }
            if (added == 0) {
                var empty = new Gtk.MenuItem.with_label (_("No applications yet. Drag a dock icon or use “Add application”."));
                empty.set_sensitive (false);
                menu.append (empty);
            }

            var controller = get_dock ();
            if (controller != null)
                Plank.Helpers.popup_docklet_menu (controller, this, menu);
            else {
                menu.show_all ();
                menu.popup_at_pointer (null);
            }
        }

        private void show_add_app_dialog () {
            var chooser = new Gtk.FileChooserDialog (
                _("Add application to %s").printf (preferences.Title),
                null,
                Gtk.FileChooserAction.OPEN,
                _("Cancel"), Gtk.ResponseType.CANCEL,
                _("Add"), Gtk.ResponseType.ACCEPT
            );
            chooser.select_multiple = true;
            var filter = new Gtk.FileFilter ();
            filter.set_filter_name (_("Applications"));
            filter.add_pattern ("*.desktop");
            chooser.add_filter (filter);
            chooser.set_current_folder ("/usr/share/applications");

            if (chooser.run () == Gtk.ResponseType.ACCEPT) {
                var uris = new ArrayList<string> ();
                foreach (var uri in chooser.get_uris ())
                    uris.add (uri);
                accept_drop (uris);
            }
            chooser.destroy ();
        }

        private const string[] GROUP_URIS = {
            "docklet://app-group",
            "docklet://app-group-2",
            "docklet://app-group-3",
            "docklet://app-group-4",
            "docklet://app-group-5",
            "docklet://app-group-6",
            "docklet://app-group-7",
            "docklet://app-group-8"
        };

        private void create_another_group () {
            var dock = get_dock ();
            if (dock == null)
                return;
            var provider = dock.default_provider;
            if (provider == null)
                return;

            foreach (var uri in GROUP_URIS) {
                var taken = false;
                foreach (var item in dock.Items) {
                    if (item.Launcher == uri) {
                        taken = true;
                        break;
                    }
                }
                if (!taken) {
                    provider.add_item_with_uri (uri, this);
                    return;
                }
            }
        }

        public override ArrayList<Gtk.MenuItem> get_menu_items () {
            var items = new ArrayList<Gtk.MenuItem> ();
            var add_item = create_menu_item (_("Add application…"), "list-add", true);
            add_item.activate.connect (() => {
                show_add_app_dialog ();
            });
            items.add (add_item);

            var new_group = create_menu_item (_("Create another folder"), "folder-new", true);
            new_group.activate.connect (() => {
                create_another_group ();
            });
            items.add (new_group);

            var folder_item = create_menu_item (_("Open group folder"), "folder-open", true);
            folder_item.activate.connect (() => {
                try {
                    AppInfo.launch_default_for_uri (File.new_for_path (expanded_folder ()).get_uri (), null);
                } catch (Error error) {
                    warning ("Cannot open group folder: %s", error.message);
                }
            });
            items.add (folder_item);

            var rename_item = create_menu_item (_("Rename group"), "edit-rename", true);
            rename_item.activate.connect (() => {
                show_rename_dialog ();
            });
            items.add (rename_item);

            var icon_item = create_menu_item (_("Change icon…"), "insert-image", true);
            icon_item.activate.connect (() => {
                show_icon_dialog ();
            });
            items.add (icon_item);

            var remove_item = create_menu_item (_("Remove this group from the dock"), "list-remove", true);
            remove_item.activate.connect (() => {
                this.@delete ();
            });
            items.add (remove_item);
            return items;
        }
    }
}
