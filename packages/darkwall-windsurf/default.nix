# TEAM_427: darkwall-windsurf - Windsurf IDE with darkwall customizations
#
# Structure:
#   packages/darkwall-windsurf/
#   ├── default.nix      # Entry point (calls this file)
#   ├── package.nix      # Package derivation (this file)
#   └── dotfiles/        # Customizations to install
#       ├── mcp_config.json
#       ├── global_rules.md
#       └── workflows/
#
{ lib
, stdenv
, fetchurl
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, wrapGAppsHook3
, autoPatchelfHook
# Runtime dependencies
, libsecret
, libXScrnSaver
, libxshmfence
, libxkbfile
, libGL
, alsa-lib
, at-spi2-atk
, at-spi2-core
, atk
, cairo
, cups
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libdrm
, libX11
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXtst
, mesa
, nspr
, nss
, pango
, systemd
, vulkan-loader
, xorg
, krb5
}:

let
  version = "1.12.39";
  
  # Fetch latest from: curl -s "https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest"
  src = fetchurl {
    url = "https://windsurf-stable.codeiumdata.com/linux-x64/stable/10ebfa84f4e8b018ef2459063f0293b8e9ac01da/Windsurf-linux-x64-${version}.tar.gz";
    sha256 = "sha256-zjbshpfKfJdoZ4uZubizZNM6BEr+0kKTH+oU9URYHGg=";
  };


  desktopItem = makeDesktopItem {
    name = "darkwall-windsurf";
    desktopName = "Windsurf (darkwall)";
    comment = "Code Editing. Redefined. With darkwall customizations.";
    genericName = "Text Editor";
    exec = "darkwall-windsurf %F";
    icon = "windsurf";
    startupNotify = true;
    startupWMClass = "Windsurf";
    categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    keywords = [ "vscode" "windsurf" "darkwall" ];
    actions.new-empty-window = {
      name = "New Empty Window";
      exec = "darkwall-windsurf --new-window %F";
      icon = "windsurf";
    };
    mimeTypes = [
      "text/plain"
      "inode/directory"
      "application/x-code-workspace"
    ];
  };

  # TEAM_433: URL handler for OAuth callbacks (windsurf:// and vscode:// schemes)
  urlHandlerDesktopItem = makeDesktopItem {
    name = "darkwall-windsurf-url-handler";
    desktopName = "Windsurf (darkwall) - URL Handler";
    comment = "Code Editing. Redefined.";
    genericName = "Text Editor";
    exec = "darkwall-windsurf --open-url %U";
    icon = "windsurf";
    startupNotify = true;
    startupWMClass = "Windsurf";
    categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    mimeTypes = [
      "x-scheme-handler/windsurf"
      "x-scheme-handler/vscode"  # Many OAuth services use vscode:// protocol
    ];
    noDisplay = true;
  };

  runtimeDeps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libdrm
    libGL
    libsecret
    libX11
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libxkbfile
    libXrandr
    libXrender
    libXScrnSaver
    libxshmfence
    libXtst
    mesa
    nspr
    nss
    pango
    systemd
    vulkan-loader
    xorg.libxcb
    krb5
  ];

in stdenv.mkDerivation {
  pname = "darkwall-windsurf";
  inherit version src;

  sourceRoot = ".";

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
    wrapGAppsHook3
    autoPatchelfHook
  ];

  buildInputs = runtimeDeps;

  dontConfigure = true;
  dontBuild = true;
  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall

    # Install Windsurf
    mkdir -p $out/lib/windsurf $out/bin
    cp -r Windsurf/* $out/lib/windsurf/


    # Create wrapper with LD_LIBRARY_PATH
    makeWrapper $out/lib/windsurf/windsurf $out/bin/darkwall-windsurf \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeDeps} \
      "''${gappsWrapperArgs[@]}"

    # Also provide plain 'windsurf' symlink
    ln -s $out/bin/darkwall-windsurf $out/bin/windsurf

    # Install icons
    for size in 16 32 48 64 128 256 512; do
      install -Dm644 $out/lib/windsurf/resources/app/resources/linux/code.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/windsurf.png || true
    done
    install -Dm644 $out/lib/windsurf/resources/app/resources/linux/code.png \
      $out/share/pixmaps/windsurf.png || true

    runHook postInstall
  '';

  desktopItems = [
    desktopItem
    urlHandlerDesktopItem
  ];

  meta = with lib; {
    description = "Windsurf IDE (binary only - darkwall customizations via home-manager)";
    homepage = "https://codeium.com/windsurf";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "darkwall-windsurf";
  };
}
