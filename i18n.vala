namespace PlankGroup {
    public void init_i18n () {
        Intl.bindtextdomain (Build.GETTEXT_PACKAGE, Build.LOCALEDIR);
        Intl.bind_textdomain_codeset (Build.GETTEXT_PACKAGE, "UTF-8");
    }

    public unowned string _ (string msgid) {
        return GLib.dgettext (Build.GETTEXT_PACKAGE, msgid);
    }
}
