namespace PlankGroup {
    public class AppGroupPreferences : Plank.DockItemPreferences {
        [Description (nick = "title", blurb = "Name shown when hovering over the group")]
        public string Title { get; set; default = "Applications"; }

        [Description (nick = "icon", blurb = "Icon theme name for this category")]
        public string GroupIcon { get; set; default = "/usr/share/icons/Humanity/places/64/folder.svg"; }

        [Description (nick = "folder", blurb = "Folder containing .desktop launchers")]
        public string Folder { get; set; default = ""; }

        public AppGroupPreferences.with_file (GLib.File file) {
            base.with_file (file);
        }

        protected override void reset_properties () {
            Title = "Applications";
            GroupIcon = "/usr/share/icons/Humanity/places/64/folder.svg";
            Folder = "";
        }
    }
}
