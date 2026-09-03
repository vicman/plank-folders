public static void docklet_init (Plank.DockletManager manager) {
    manager.register_docklet (typeof (PlankGroup.AppGroupDocklet));
}

namespace PlankGroup {
    public class AppGroupDocklet : Object, Plank.Docklet {
        public unowned string get_id () { return "app-group"; }
        public unowned string get_name () { return _("Application group"); }
        public unowned string get_description () { return _("Launch the applications in one category"); }
        public unowned string get_icon () { return "/usr/share/icons/Humanity/places/64/folder.svg"; }
        public bool is_supported () { return true; }
        public Plank.DockElement make_element (string launcher, GLib.File file) {
            return new AppGroupItem.with_dockitem_file (file);
        }
    }
}
