import ../make-test-python.nix (
  { pkgs, ... }:
  {
    name = "kerberos_server-mit";

    nodes.machine =
      {
        config,
        libs,
        pkgs,
        ...
      }:
      {
        services.kerberos_server = {
          enable = true;
          settings.realms = {
            "FOO.BAR".acl = [
              {
                principal = "admin";
                access = [
                  "add"
                  "cpw"
                ];
              }
            ];
          };
        };
        security.krb5 = {
          enable = true;
          package = pkgs.krb5;
          settings = {
            libdefaults = {
              default_realm = "FOO.BAR";
            };
            realms = {
              "FOO.BAR" = {
                admin_server = "machine";
                kdc = "machine";
              };
            };
          };
        };
        users.extraUsers.alice = {
          isNormalUser = true;
        };
      };

    testScript = ''
      machine.succeed(
          "kdb5_util create -s -r FOO.BAR -P master_key",
          "systemctl restart kadmind.service kdc.service",
      )

      for unit in ["kadmind", "kdc"]:
          machine.wait_for_unit(f"{unit}.service")

      machine.succeed(
          "kadmin.local add_principal -pw admin_pw admin",
          "kadmin -p admin -w admin_pw addprinc -pw alice_pw alice",
          "echo alice_pw | sudo -u alice kinit",
      )
    '';

    meta.maintainers = [ pkgs.lib.maintainers.dblsaiko ];
  }
)
