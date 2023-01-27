{ pkgs, config, ...}:
{
  networking = {
    hostName = "hashmap";
    domain = "local";
    search = [ "local" ];
    firewall.allowedTCPPorts = [ ];
    firewall.extraCommands = '' '';
  };

  boot = {
    supportedFilesystems = ["ntfs"];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    initrd.luks.devices = {
      luksroot = {
        device = "/dev/nvme0n1p1";
        preLVM = true;
        allowDiscards = true;
      };
      luks-data = {
        device = "/dev/sda1";
        preLVM = true;
        allowDiscards = true;
      };
    };
    loader.grub = {
      enable = false;
      device = "/dev/sda1";
      configurationLimit = 3;
    };
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_CTYPE="en_DK.UTF-8";
      LC_TIME="en_DK.UTF-8";
      LC_PAPER="en_DK.UTF-8";
      LC_NAME="en_DK.UTF-8";
      LC_ADDRESS="en_DK.UTF-8";
      LC_TELEPHONE="en_DK.UTF-8";
      LC_MEASUREMENT="en_DK.UTF-8";
      LC_IDENTIFICATION="en_DK.UTF-8";
    };
  };

  time.timeZone = "Europe/Oslo";

  features = {
    desktop.enable = true;
    laptop.enable = false;
    desktop.wayland.enable = true;
    desktop.hyprland.enable = true;
    desktop.keybase.enable = true;
    cachix.enable = true;

    pki = {
      enable = false;
      certmgr.enable = true;
      certs = {
        foo = { hosts = [ "localhost" ]; };
      };
    };

    os = {
      networkmanager.enable = true;
      externalInterface = "eno2";

      docker.enable = true;

      adminAuthorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDULdlLC8ZLu9qBZUYsjhpr6kv5RH4yPkekXQdD7prkqapyoptUkO1nOTDwy7ZsKDxmp9Zc6OtdhgoJbowhGW3VIZPmooWO8twcaYDpkxEBLUehY/n8SlAwBtiHJ4mTLLcynJMVrjmTQLF3FeWVof0Aqy6UtZceFpLp1eNkiHTCM3anwtb9+gfr91dX1YsAOqxqv7ooRDu5rCRUvOi4OvRowepyuBcCjeWpTkJHkC9WGxuESvDV3CySWkGC2fF2LHkAu6SFsFE39UA5ZHo0b1TK+AFqRFiBAb7ULmtuno1yxhpBxbozf8+Yyc7yLfMNCyBpL1ci7WnjKkghQv7yM1xN2XMJLpF56v0slSKMoAs7ThoIlmkRm/6o3NCChgu0pkpNg/YP6A3HfYiEDgChvA6rAHX6+to50L9xF3ajqk4BUzWd/sCk7Q5Op2lzj31L53Ryg8vMP8hjDjYcgEcCCsGOcjUVgcsmfC9LupwRIEz3aF14AWg66+3zAxVho8ozjes= jonas.juselius@juselius.io"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFbrEhm1acesXmbgfO5lN1gcTFXqusq61QyCZXunYJpl"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIdcJteh9d/N1o8BbdEMRVxeMjm28saon/Oh2tV0+TYj"
      ];

      nfs.enable = false;
      # nfs.exports = ''
      #   /exports 10.1.1.0/24(insecure,ro,async,crossmnt,no_subtree_check,fsid=0,no_root_squash)
      # '';
    };

    lan = {
      enable = true;

      krb5 = {
        enable = false;
        default_realm = "ACME";

        domain_realm = {
          "acme.com" = "ACME";
        };

        realms = {
          "ACME" = {
            admin_server = "dc.acme.com";
            kdc = "dc.acme.com";
          };
        };
      };
    };
  };


  services.dnsmasq.enable = true;
  services.dnsmasq.settings = {
      address = [
        "/.local/127.0.0.1"
        "/.local.oceanbox.io/127.0.0.1"
      ];
      addn-hosts = "/etc/hosts.adhoc";
  };

  programs.singularity.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.bluetooth.settings = {
    General = {
      AutoConnct = true;
      MultiProfile = "multiple";
    };
  };

  services.pcscd.enable = false; # For Yubikey ykman

  security.pam.yubico = {
    enable = false;
    mode = "client"; # "challenge-response";
    id = "92753";
    control = "sufficient";
  };

  services.udev.extraRules = ''
      ACTION=="remove",\
      ENV{ID_BUS}=="usb",\
      ENV{ID_MODEL_ID}=="0407",\
      ENV{ID_VENDOR_ID}=="1050",\
      ENV{ID_VENDOR}=="Yubico",\
      RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
  '';

  nixpkgs.config.allowUnfreee = true;

  services.tailscale =  {
    enable = true;
    useRoutingFeatures = "client";
    extraUpFlags = [
      "--login-server=https://headscale.svc.oceanbox.io"
      "--accept-dns=true"
      "--accept-routes"
    ];
  };

  imports = [
    ./.
    ./kernel.nix
    ./hardware-configuration.nix
    #"${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; }}/lenovo/thinkpad/x1/7th-gen"
  ];

}

