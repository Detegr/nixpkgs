{
  lib,
  buildNpmPackage,
  fetchFromGitLab,
  makeDesktopItem,
  copyDesktopItems,
  makeWrapper,
  electron,
  rsync,
}:

buildNpmPackage rec {
  pname = "fcast-receiver";
  version = "2.0.0";

  src = fetchFromGitLab {
    domain = "gitlab.futo.org";
    owner = "videostreaming";
    repo = "fcast";
    rev = "13ed62a0ff12c1ec03c331fd3f50c14c57eedee7";
    hash = "sha256-jDHgr3hPUBZqO0+NbUbYP+/HxmWCr+ragex7GvOupSg=";
  };

  sourceRoot = "${src.name}/receivers/electron";

  makeCacheWritable = true;

  npmDepsHash = "sha256-cyGKwcMcOPUO8DzUih/mv492zQGWPhRBkVX5ULMIs8Y=";

  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  desktopItems = [
    (makeDesktopItem {
      name = pname;
      desktopName = "FCast Receiver";
      genericName = "Media Streaming Receiver";
      exec = "fcast-receiver";
      icon = "fcast-receiver";
      comment = "FCast Receiver, an open-source media streaming receiver";
    })
  ];

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
    rsync
  ];

  postInstall = ''
    install -Dm644 $out/lib/node_modules/fcast-receiver/dist/icon.png $out/share/pixmaps/fcast-receiver.png
    ln -s $out/lib/node_modules/fcast-receiver/package.json $out/lib/node_modules/fcast-receiver/dist/package.json

    makeWrapper ${electron}/bin/electron $out/bin/fcast-receiver \
      --add-flags $out/lib/node_modules/fcast-receiver/dist/bundle.js
  '';

  meta = with lib; {
    description = "FCast Receiver, an open-source media streaming receiver";
    longDescription = ''
      FCast Receiver is a receiver for an open-source media streaming protocol, FCast, an alternative to Chromecast and AirPlay.
    '';
    homepage = "https://fcast.org/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ ymstnt ];
    mainProgram = "fcast-receiver";
    platforms = platforms.linux;
  };
}
