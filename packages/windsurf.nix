# Custom Windsurf package - maintained by darkwall
# Based on nixpkgs vscode derivation pattern
{ lib
, stdenv
, fetchurl
, makeWrapper
, makeDesktopItem
, copyDesktopItems
, wrapGAppsHook3
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
, autoPatchelfHook
}:

let
  version = "1.12.39";
  
  # Fetch latest from: curl -s "https://windsurf-stable.codeium.com/api/update/linux-x64/stable/latest"
  src = fetchurl {
    url = "https://windsurf-stable.codeiumdata.com/linux-x64/stable/10ebfa84f4e8b018ef2459063f0293b8e9ac01da/Windsurf-linux-x64-${version}.tar.gz";
    sha256 = "sha256-zjbshpfKfJdoZ4uZubizZNM6BEr+0kKTH+oU9URYHGg=";
  };

  desktopItem = makeDesktopItem {
    name = "windsurf";
    desktopName = "Windsurf";
    comment = "Code Editing. Redefined.";
    genericName = "Text Editor";
    exec = "windsurf %F";
    icon = "windsurf";
    startupNotify = true;
    startupWMClass = "Windsurf";
    categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    keywords = [ "vscode" ];
    actions.new-empty-window = {
      name = "New Empty Window";
      exec = "windsurf --new-window %F";
      icon = "windsurf";
    };
    mimeTypes = [
      "text/plain"
      "inode/directory"
      "application/x-code-workspace"
    ];
  };

  urlHandlerDesktopItem = makeDesktopItem {
    name = "windsurf-url-handler";
    desktopName = "Windsurf - URL Handler";
    comment = "Code Editing. Redefined.";
    genericName = "Text Editor";
    exec = "windsurf --open-url %U";
    icon = "windsurf";
    startupNotify = true;
    startupWMClass = "Windsurf";
    categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    mimeTypes = [ "x-scheme-handler/windsurf" ];
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
  pname = "windsurf";
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

    mkdir -p $out/lib/windsurf $out/bin
    cp -r Windsurf/* $out/lib/windsurf/

    # Create wrapper
    makeWrapper $out/lib/windsurf/windsurf $out/bin/windsurf \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeDeps} \
      "''${gappsWrapperArgs[@]}"

    # Install icons
    for size in 16 32 48 64 128 256 512; do
      install -Dm644 $out/lib/windsurf/resources/app/resources/linux/code.png \
        $out/share/icons/hicolor/''${size}x''${size}/apps/windsurf.png || true
    done

    # Fallback icon
    install -Dm644 $out/lib/windsurf/resources/app/resources/linux/code.png \
      $out/share/pixmaps/windsurf.png || true

    runHook postInstall
  '';

  desktopItems = [
    desktopItem
    urlHandlerDesktopItem
  ];

  meta = with lib; {
    description = "Codeium's AI-powered IDE based on VS Code";
    homepage = "https://codeium.com/windsurf";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "windsurf";
  };
}
