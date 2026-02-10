# Sine — mod/theme manager for Zen Browser
# Installs fx-autoconfig (JS loader) + Sine engine into a declarative Zen profile.
# https://github.com/CosmoCreeper/Sine
# https://github.com/MrOtherGuy/fx-autoconfig
{
  config,
  inputs,
  pkgs,
  ...
}:

let
  inherit (config.fracture.user) login;

  fx-autoconfig-src = pkgs.fetchFromGitHub {
    owner = "MrOtherGuy";
    repo = "fx-autoconfig";
    rev = "76232083171a8d609bf0258549d843b0536685e1";
    hash = "sha256-xiCikg8c855w+PCy7Wmc3kPwIHr80pMkkK7mFQbPCs4=";
  };

  sine-src = pkgs.fetchFromGitHub {
    owner = "CosmoCreeper";
    repo = "Sine";
    rev = "1444c962a871d44c6f8d44317656430827951194";
    hash = "sha256-E/2gS2oiFUHe85qW1IE2A6zPDr5Ow+lMu3Y0jMPv9+o=";
  };

  # fx-autoconfig bootstrap — gets injected into mozilla.cfg via wrapFirefox's extraPrefs.
  # Registers the chrome manifest and loads the boot module, which then scans
  # chrome/JS/ for scripts (including Sine's engine).
  bootstrapJS = ''
    // fx-autoconfig bootstrap
    try {
      let cmanifest = Cc["@mozilla.org/file/directory_service;1"]
        .getService(Ci.nsIProperties)
        .get("UChrm", Ci.nsIFile);
      cmanifest.append("utils");
      cmanifest.append("chrome.manifest");
      if (cmanifest.exists()) {
        Components.manager.QueryInterface(Ci.nsIComponentRegistrar)
          .autoRegister(cmanifest);
        ChromeUtils.importESModule("chrome://userchromejs/content/boot.sys.mjs");
      }
    } catch(e) {
      console.error(e);
    }
  '';

  profileName = "default";
  profilePath = ".zen/${profileName}";

  zenPackage =
    (inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.twilight.override {
      extraPrefs = bootstrapJS;
    }).overrideAttrs
      (prev: {
        buildCommand = prev.buildCommand + ''
          # zen-browser-flake sets applicationName to a display string that doesn't
          # match the binary filename, so wrapFirefox symlinks the binary instead of
          # copying it. Firefox resolves symlinks to find its app directory, which
          # means it looks for autoconfig in the unwrapped package (where there is
          # none). Fix by replacing the symlinks with copies.
          for bin in "$out"/lib/*/zen "$out"/lib/*/zen-bin; do
            if [ -L "$bin" ]; then
              target=$(readlink -f "$bin")
              rm "$bin"
              cp "$target" "$bin"
            fi
          done
          echo 'pref("general.config.sandbox_enabled", false);' >> "$out"/lib/*/defaults/pref/autoconfig.js
        '';
      });
in
{
  home-manager.users.${login} = _: {
    # Override browser package to include fx-autoconfig bootstrap in mozilla.cfg
    # and disable the autoconfig sandbox so the bootstrap can access XPCOM.
    # This only rebuilds the thin wrapFirefox wrapper (symlinks + config), not the engine.
    programs.zen-browser.package = zenPackage;

    # Deterministic profile path at ~/.zen/default/
    programs.zen-browser.profiles.${profileName} = {
      isDefault = true;
    };

    # Launcher with absolute path so Vicinae always uses the overridden binary
    xdg.desktopEntries.zen-moonlight = {
      name = "Zen Moonlight";
      genericName = "Web Browser";
      exec = "${zenPackage}/bin/zen-twilight --name zen-moonlight %U";
      icon = "zen-twilight";
      categories = [
        "Network"
        "WebBrowser"
      ];
      mimeType = [
        "text/html"
        "text/xml"
        "application/xhtml+xml"
        "application/vnd.mozilla.xul+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
      ];
      terminal = false;
      type = "Application";
      settings = {
        StartupWMClass = "zen-twilight";
        StartupNotify = "true";
      };
      actions = {
        new-window = {
          name = "New Window";
          exec = "${zenPackage}/bin/zen-twilight --new-window %U";
        };
        new-private-window = {
          name = "New Private Window";
          exec = "${zenPackage}/bin/zen-twilight --private-window %U";
        };
      };
    };

    # fx-autoconfig loader infrastructure
    home.file."${profilePath}/chrome/utils" = {
      source = "${fx-autoconfig-src}/profile/chrome/utils";
      recursive = true;
    };

    # Sine engine + bootloader
    home.file."${profilePath}/chrome/JS/engine" = {
      source = "${sine-src}/engine";
      recursive = true;
    };
    home.file."${profilePath}/chrome/JS/sine.sys.mjs" = {
      source = "${sine-src}/sine.sys.mjs";
    };

    # Sine locales
    home.file."${profilePath}/chrome/locales" = {
      source = "${sine-src}/locales";
      recursive = true;
    };
  };
}
