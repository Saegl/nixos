{...}: {
  xdg.enable = true;
  xdg.mime.enable = true;
  xdg.mimeApps.enable = true;
  xdg.mimeApps.defaultApplications = {
    "image/svg+xml" = "org.gnome.Loupe.desktop";
    "image/png" = "org.gnome.Loupe.desktop";
    "image/jpeg" = "org.gnome.Loupe.desktop";
    "image/jpg" = "org.gnome.Loupe.desktop"; # Optional: 'jpg' is technically just a common extension for 'jpeg'
    "application/pdf" = "org.pwmt.zathura.desktop";
    "application/postscript" = "org.pwmt.zathura.desktop";
    "application/vnd.comicbook+zip" = "org.pwmt.zathura.desktop";
    "application/vnd.comicbook-rar" = "org.pwmt.zathura.desktop";
    "application/vnd.ms-xpsdocument" = "org.pwmt.zathura.desktop";
    "application/x-bzpdf" = "org.pwmt.zathura.desktop";
    "application/x-ext-djv" = "org.pwmt.zathura.desktop";
    "application/x-ext-djvu" = "org.pwmt.zathura.desktop";
    "application/x-ext-eps" = "org.pwmt.zathura.desktop";
    "application/x-ext-pdf" = "org.pwmt.zathura.desktop";
    "application/x-gzpdf" = "org.pwmt.zathura.desktop";
    "application/x-xzpdf" = "org.pwmt.zathura.desktop";
    "image/tiff" = "org.pwmt.zathura.desktop";
    "image/vnd.djvu+multipage" = "org.pwmt.zathura.desktop";
    "image/x-bzeps" = "org.pwmt.zathura.desktop";
    "image/x-eps" = "org.pwmt.zathura.desktop";
    "image/x-gzeps" = "org.pwmt.zathura.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
    "x-scheme-handler/chrome" = "firefox.desktop";
    "text/html" = "firefox.desktop";
    "application/x-extension-htm" = "firefox.desktop";
    "application/x-extension-html" = "firefox.desktop";
    "application/x-extension-shtml" = "firefox.desktop";
    "application/xhtml+xml" = "firefox.desktop";
    "application/x-extension-xhtml" = "firefox.desktop";
    "application/x-extension-xht" = "firefox.desktop";
  };
}
