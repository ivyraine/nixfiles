# Provide a basic configuration for installation devices like CDs.
{ config, pkgs, lib, modulesPath, ... }:

with lib;

let
  rnst_keycodes = pkgs.writeText "rnst_keycodes" ''
    xkb_keycodes  { include "evdev+aliases(qwerty)"  };
  '';
  rnst_types = pkgs.writeText "rnst_types" ''
    xkb_types     { include "complete"	};
  '';
  rnst_compat = pkgs.writeText "rnst_compat" ''
    xkb_compat    { include "complete"	};
  '';
  rnst_geometry = pkgs.writeText "rnst_geometry" ''
    xkb_geometry  { include "pc(pc105)"	};
  '';
  rnst_symbols = pkgs.writeText "rnst_symbols" ''
    xkb_symbols   {
      include "pc+us(dvp)+inet(evdev)"

      key <TLDE> { [dead_grave, dead_tilde,         grave,       asciitilde ] };
      key <AE01> { [         1,     exclam,    exclamdown,      onesuperior ] };
      key <AE02> { [         2,         at,   twosuperior, dead_doubleacute ] };
      key <AE03> { [         3, numbersign, threesuperior,      dead_macron ] };
      key <AE04> { [         4,     dollar,      currency,         sterling ] };
      key <AE05> { [         5,    percent,      EuroSign,     dead_cedilla ] };
      key <AE06> { [    6, dead_circumflex,    onequarter,      asciicircum ] };
      key <AE07> { [         7,  ampersand,       onehalf,        dead_horn ] };
      key <AE08> { [         8,   asterisk, threequarters,      dead_ogonek ] };
      key <AE09> { [         9,  parenleft, leftsinglequotemark, dead_breve ] };
      key <AE10> { [         0, parenright, rightsinglequotemark, dead_abovering ] };
      key <AE11> { [     minus, underscore,           yen,    dead_belowdot ] };
      key <AE12> { [     equal,       plus,      multiply,         division ] };

      key <AD01> { [         l,          L,    adiaeresis,       Adiaeresis ] };
      key <AD02> { [         h,          H,         aring,            Aring ] };
      key <AD03> { [         d,          D,        eacute,           Eacute ] };
      key <AD04> { [         c,          C,    registered,       registered ] };
      key <AD05> { [bracketleft, braceleft,         thorn,            THORN ] };
      key <AD06> { [         z,          Z,    udiaeresis,       Udiaeresis ] };
      key <AD07> { [bracketright,braceright,       uacute,           Uacute ] };
      key <AD08> { [         w,          W,        iacute,           Iacute ] };
      key <AD09> { [         v,          V,        oacute,           Oacute ] };
      key <AD10> { [     comma,       less,    odiaeresis,       Odiaeresis ] };
      key <AD11> { [ semicolon,      colon, guillemotleft, leftdoublequotemark ] };
      key <AD12> { [     slash,   question, guillemotright, rightdoublequotemark ] };

      key <AC01> { [         r,          R,        aacute,           Aacute ] };
      key <AC02> { [         n,          N,        ssharp,          section ] };
      key <AC03> { [         s,          S,           eth,              ETH ] };
      key <AC04> { [         t,          T,             f,                F ] };
      key <AC05> { [         p,          P,             g,                G ] };
      key <AC06> { [         x,          X,             h,                H ] };
      key <AC07> { [         u,          U,             j,                J ] };
      key <AC08> { [         i,          I,            oe,               OE ] };
      key <AC09> { [         a,          A,        oslash,         Ooblique ] };
      key <AC10> { [         e,          E,     paragraph,           degree ] };
      key <AC11> { [         o,          O,    apostrophe,         quotedbl ] };

      key <AB01> { [         m,          M,            ae,               AE ] };
      key <AB02> { [         b,          B,             x,                X ] };
      key <AB03> { [         f,          F,     copyright,             cent ] };
      key <AB04> { [         g,          G,             v,                V ] };
      key <AB05> { [         j,          J,             b,                B ] };
      key <AB06> { [         q,          Q,        ntilde,           Ntilde ] };
      key <AB07> { [apostrophe,   quotedbl,            mu,               mu ] };
      key <AB08> { [         y,          Y,      ccedilla,         Ccedilla ] };
      key <AB09> { [         k,          K, dead_abovedot,       dead_caron ] };
      key <AB10> { [    period,    greater,  questiondown,        dead_hook ] };

      key <BKSL> { [ backslash,        bar,       notsign,        brokenbar ] };

      key <LSGT> { [ backslash,   bar,            backslash,      bar ] };

      key <CAPS> { [ Escape, Escape, Escape, Escape ] };
      key <ESC>  { [ Caps_Lock, Caps_Lock, Caps_Lock, Caps_Lock ] };
      key <PRSC> { [ BackSpace, BackSpace, BackSpace, BackSpace ] };
      };
  '';

in {
  #imports = [
  #        "${modulesPath}/profiles/ivy.nix"
  #];
  imports =
    [ # Enable devices which are usually scanned, because we don't know the
      # target system.
      "${modulesPath}/installer/scan/detected.nix"
      "${modulesPath}/installer/scan/not-detected.nix"
      "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"

      # Allow "nixos-rebuild" to work properly by providing
      # /etc/nixos/configuration.nix.
      "${modulesPath}/profiles/clone-config.nix"

      # Include a copy of Nixpkgs so that nixos-install works out of
      # the box.
      "${modulesPath}/installer/cd-dvd/channel.nix"
    ];

  config = {

    virtualisation = { libvirtd = { enable = true; }; };

    nix = {
      package = pkgs.nixFlakes;
      extraOptions = "  experimental-features = nix-command flakes\n";
    };

    system.nixos.variant_id = lib.mkDefault "ivy";

    # Enable in installer, even if the minimal profile disables it.
    documentation.enable = mkImageMediaOverride true;

    # Show the manual.
    documentation.nixos.enable = mkImageMediaOverride true;

    # Use less privileged ivy user
    users.users.ivy = {
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" "video" "libvirtd" ];
      # Allow the graphical user to login without password
      initialHashedPassword = "";
    };

    # Allow the user to log in as root without a password.
    users.users.root.initialHashedPassword = "";

    # Allow passwordless sudo from nixos user
    security.sudo = {
      enable = mkDefault true;
      wheelNeedsPassword = mkImageMediaOverride false;
    };

    # Enable the X11 windowing system.
    services.xserver = {
      enable = true;

      # https://discourse.nixos.org/t/unable-to-set-custom-xkb-layout/16534
      extraLayouts.rnst = {
        description = "Ivy's keyboard";
        languages = [ "eng" ];
        typesFile = rnst_types;
        symbolsFile = rnst_symbols;
        keycodesFile = rnst_keycodes;
        geometryFile = rnst_geometry;
        compatFile = rnst_compat;
      };
      layout = "rnst";

      desktopManager = { xterm.enable = false; };

      # Don't use desktop manager.
      displayManager.defaultSession = "none+i3";

      windowManager.i3 = {
        enable = true;
        configFile = "/etc/i3config";
      };
      # displayManager.lightdm.enable = true;

      # videoDrivers = [ "nvidia" ];

      # keyboard stuff
      autoRepeatDelay = 200;
      autoRepeatInterval = 25;
    };

    # Some more help text.
    services.getty.helpLine = ''
      meow!!!!!!!!

      The "ivy" and "root" accounts have empty passwords.

      An ssh daemon is running. You then must set a password
      for either "root" or "ivy" with `passwd` or add an ssh key
      to /home/ivy/.ssh/authorized_keys be able to login.

      If you need a wireless connection, type
      `sudo systemctl start wpa_supplicant` and configure a
      network using `wpa_cli`. See the NixOS manual for details.
    '' + optionalString config.services.xserver.enable ''

      Type `sudo systemctl start display-manager' to
      start the graphical user interface.
    '' + ''

      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
      ▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▓▓▓▓▓▓▓▓
      ▓▓▓▓▓▓▓▓████████████████████▓▓▓▓▓▓  ▓▓▓▓▓▓██████░░████▓▓▓▓▓▓
      ▓▓██████▒▒▒▒▒▒▒▒▒▒▓▓▒▒▒▒▒▒▓▓██▓▓▓▓▓▓▓▓▓▓██    ██░░    ██▓▓▓▓
      ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓██▓▓▓▓▓▓██  ░░  ██░░  ██▓▓▓▓▓▓
      ██▒▒▒▒▒▒▒▒▒▒▒▒▓▓▒▒▒▒▒▒▒▒▓▓▒▒▒▒██▓▓▓▓▓▓██    ░░    ░░██████▓▓
      ██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▓▓▓▓▒▒██▓▓▓▓▓▓██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
      ▓▓██████▒▒▒▒▒▒▒▒▒▒▓▓░░░░░░░░████▓▓▓▓██▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒██
      ▓▓▓▓▓▓▓▓████▒▒▒▒▓▓░░░░░░░░░░████▓▓▓▓██░░▒▒▒▒▒▒░░▒▒▒▒▒▒▒▒▒▒██
      ▓▓▓▓▓▓▓▓▓▓██▓▓▓▓▓▓▓▓░░░░░░██▓▓██▓▓▓▓██░░▒▒░░▒▒▒▒▒▒░░▒▒▒▒░░██
      ▓▓▓▓▓▓▓▓██▓▓▒▒▒▒▒▒▒▒▒▒▓▓▓▓████▓▓▓▓▓▓▓▓██▒▒▒▒▒▒▒▒▒▒░░░░▒▒██▓▓
      ▓▓▓▓▓▓▓▓██▒▒▒▒▒▒▒▒▒▒░░░░▒▒▒▒░░██▓▓▓▓▓▓▓▓██▒▒▒▒▒▒▒▒░░▒▒██▓▓▓▓
        ▓▓▓▓▓▓██▒▒▒▒▓▓▒▒▒▒░░░░▒▒▒▒░░██▓▓▓▓▓▓▓▓▓▓██▒▒▒▒▒▒▒▒██▓▓▓▓▓▓
      ▓▓▓▓▓▓▓▓██░░▒▒▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▓▓▓▓▓▓▓▓▓▓▓▓▓▓████████▓▓▓▓▓▓▓▓
      ▓▓▓▓▓▓██░░▒▒▒▒▓▓▓▓▒▒▒▒▒▒▒▒▓▓██▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
      ▓▓▓▓▓▓██░░░░██▓▓▒▒▒▒▓▓▓▓▓▓▒▒██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
      ▓▓▓▓▓▓▓▓████▓▓██▒▒▒▒▒▒██▒▒▒▒██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓
      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓██▒▒░░██▒▒░░██▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
      ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓████▓▓██████▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓
      ▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓
    '';

    # We run sshd by default. Login via root is only possible after adding a
    # password via "passwd" or by adding a ssh key to /home/nixos/.ssh/authorized_keys.
    # The latter one is particular useful if keys are manually added to
    # installation device for head-less systems i.e. arm boards by manually
    # mounting the storage in a different system.
    services.openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };

    networking.networkmanager.enable = true;
    # The default gateway can be found with `ip route show` or `netstat -rn`.
    networking.defaultGateway = "10.0.0.1";
    networking.nameservers = [ "8.8.8.8" ];
    networking.interfaces.wlan0.ipv4.addresses = [{
      # Note: This address (of course) must be a valid address w.r.t. subnet mask.
      # Can be found with `ifconfig <interface>`. wlan0 is one such interface.
      address = "10.0.0.168";
      prefixLength = 24;
    }];

    programs.zsh.enable = true;
    programs.zsh.autosuggestions.enable = true;
    programs.zsh.syntaxHighlighting.enable = true;
    programs.zsh.ohMyZsh.enable = true;
    programs.zsh.ohMyZsh.plugins = [ "autojump" "git" ];
    programs.zsh.ohMyZsh.theme = "robbyrussell";

    # Tell the Nix evaluator to garbage collect more aggressively.
    # This is desirable in memory-constrained environments that don't
    # (yet) have swap set up.
    environment.variables.GC_INITIAL_HEAP_SIZE = "1M";
    environment.systemPackages = with pkgs; [
      alacritty
      pkgs.xorg.xkbcomp
      pkgs.gitAndTools.gitFull
      tmux
      neovim
    ];
    
    environment.sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "chromium";
      TERM = "alacritty";
      TERMINAL = "alacritty";
    };
    environment.etc."i3config".text = (import ./pkgs/i3config.nix { inherit pkgs; });
    
    fonts.fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "Hack" ]; })
    ];

    # Make the installer more likely to succeed in low memory
    # environments.  The kernel's overcommit heustistics bite us
    # fairly often, preventing processes such as nix-worker or
    # download-using-manifests.pl from forking even if there is
    # plenty of free memory.
    # boot.kernel.sysctl."vm.overcommit_memory" = "1";

    # To speed up installation a little bit, include the complete
    # stdenv in the Nix store on the CD.
    system.extraDependencies = with pkgs; [
      stdenv
      stdenvNoCC # for runCommand
      # busybox
      # For boot.initrd.systemd
      makeInitrdNGTool
      systemdStage1
      systemdStage1Network
    ];
    system.stateVersion = "22.11";

    networking.firewall.enable = false;
  };
}
