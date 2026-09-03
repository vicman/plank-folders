/**
 * Plank Group Docklet
 * A category launcher for Plank Reloaded.
 *
 * Plank Reloaded only allows one instance per docklet URI, except for the
 * separator.  Register several group ids so the user can have more than
 * one folder on the dock.
 */
public static void docklet_init (Plank.DockletManager manager) {
    PlankGroup.init_i18n ();
    manager.register_docklet (typeof (PlankGroup.AppGroupDocklet));
    manager.register_docklet (typeof (PlankGroup.AppGroupDocklet2));
    manager.register_docklet (typeof (PlankGroup.AppGroupDocklet3));
    manager.register_docklet (typeof (PlankGroup.AppGroupDocklet4));
    manager.register_docklet (typeof (PlankGroup.AppGroupDocklet5));
    manager.register_docklet (typeof (PlankGroup.AppGroupDocklet6));
    manager.register_docklet (typeof (PlankGroup.AppGroupDocklet7));
    manager.register_docklet (typeof (PlankGroup.AppGroupDocklet8));
}

namespace PlankGroup {
    public class AppGroupDocklet : Object, Plank.Docklet {
        public virtual unowned string get_id () {
            return "app-group";
        }

        public virtual unowned string get_name () {
            return _("Application group");
        }

        public unowned string get_description () {
            return _("Launch the applications in one category");
        }

        public unowned string get_icon () {
            return "/usr/share/icons/Humanity/places/64/folder.svg";
        }

        public bool is_supported () {
            return true;
        }

        public Plank.DockElement make_element (string launcher, GLib.File file) {
            return new AppGroupItem.with_dockitem_file (file);
        }
    }

    public class AppGroupDocklet2 : AppGroupDocklet {
        public override unowned string get_id () { return "app-group-2"; }
        public override unowned string get_name () { return _("Application group 2"); }
    }

    public class AppGroupDocklet3 : AppGroupDocklet {
        public override unowned string get_id () { return "app-group-3"; }
        public override unowned string get_name () { return _("Application group 3"); }
    }

    public class AppGroupDocklet4 : AppGroupDocklet {
        public override unowned string get_id () { return "app-group-4"; }
        public override unowned string get_name () { return _("Application group 4"); }
    }

    public class AppGroupDocklet5 : AppGroupDocklet {
        public override unowned string get_id () { return "app-group-5"; }
        public override unowned string get_name () { return _("Application group 5"); }
    }

    public class AppGroupDocklet6 : AppGroupDocklet {
        public override unowned string get_id () { return "app-group-6"; }
        public override unowned string get_name () { return _("Application group 6"); }
    }

    public class AppGroupDocklet7 : AppGroupDocklet {
        public override unowned string get_id () { return "app-group-7"; }
        public override unowned string get_name () { return _("Application group 7"); }
    }

    public class AppGroupDocklet8 : AppGroupDocklet {
        public override unowned string get_id () { return "app-group-8"; }
        public override unowned string get_name () { return _("Application group 8"); }
    }
}
