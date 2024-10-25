{
  buildGoModule,
  buildNpmPackage,
  fetchFromGitHub,
  lib,
  restic,
  util-linux,
  stdenv,
}:
let
  pname = "backrest";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "garethgeorge";
    repo = "backrest";
    rev = "refs/tags/v${version}";
    hash = "sha256-qzqchnDB65i+adRxlHgWfokURA7B0bAeea0TQOZrPiY=";
  };

  frontend = buildNpmPackage {
    inherit version;
    pname = "${pname}-webui";
    src = "${src}/webui";

    npmDepsHash = "sha256-x0aVi2iqw1X2MrdVY2o3B4NcZOrstG7Ig07JZXGqGrg=";

    installPhase = ''
      runHook preInstall
      mkdir $out
      cp -r dist/* $out
      runHook postInstall
    '';
  };
in
buildGoModule {
  inherit pname src version;

  vendorHash = "sha256-GQ75ZiiETgyVaSGAlgs8JQJLpLiriAzMa8kyDCk86Gc=";

  preBuild = ''
    mkdir -p ./webui/dist
    cp -r ${frontend}/* ./webui/dist
  '';

  nativeCheckInputs = [ util-linux ];

  checkFlags =
    let
      skippedTests =
        [
          "TestServeIndex" # Fails with handler returned wrong content encoding
        ]
        ++ lib.optionals stdenv.isDarwin [
          "TestBackup" # relies on ionice
        ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  preCheck = ''
    # Use restic from nixpkgs, otherwise download fails in sandbox
    export BACKREST_RESTIC_COMMAND="${restic}/bin/restic"
    export HOME=$(pwd)
  '';

  meta = {
    description = "Web UI and orchestrator for restic backup";
    homepage = "https://github.com/garethgeorge/backrest";
    changelog = "https://github.com/garethgeorge/backrest/releases/tag/v${version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ interdependence ];
    mainProgram = "backrest";
    platforms = lib.platforms.unix;
  };
}
