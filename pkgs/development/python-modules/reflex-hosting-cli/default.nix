{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  charset-normalizer,
  httpx,
  pipdeptree,
  platformdirs,
  pydantic,
  python-dateutil,
  pyyaml,
  rich,
  tabulate,
  typer,
  websockets,
}:

buildPythonPackage rec {
  pname = "reflex-hosting-cli";
  version = "0.1.50";
  pyproject = true;

  # source is not published https://github.com/reflex-dev/reflex/issues/3762
  src = fetchPypi {
    pname = "reflex_hosting_cli";
    inherit version;
    hash = "sha256-1ZTTc09P/0rTNhiqsNDB2RMLcUjKt1rIWtufakkFWkg=";
  };

  pythonRelaxDeps = [
    "rich"
    "pipdeptree"
  ];

  build-system = [ hatchling ];

  dependencies = [
    charset-normalizer
    httpx
    pipdeptree
    platformdirs
    pydantic
    python-dateutil
    pyyaml
    rich
    tabulate
    typer
    websockets
  ];

  pythonImportsCheck = [
    "reflex_cli"
    "reflex_cli.cli"
    "reflex_cli.deployments"
  ];

  # no tests on pypi
  doCheck = false;

  meta = with lib; {
    description = "Reflex Hosting CLI";
    homepage = "https://pypi.org/project/reflex-hosting-cli/";
    license = licenses.asl20;
    maintainers = with maintainers; [ pbsds ];
  };
}
