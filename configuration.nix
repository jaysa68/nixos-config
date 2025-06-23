# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.device = "nodev"; # todo : change me once the system booted
  boot.loader.grub.efiInstallAsRemovable = true;
  boot.tmp.useTmpfs = true;

  # allow unfree pkgs
  nixpkgs.config.allowUnfree = true;

  # DONT Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.hostName = "lola"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  programs.dconf.profiles.user.databases = [
    {
      lockAll = true; # prevents overriding
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
	"org/gnome/desktop/background" = let
	  dark-bg = "/home/jaysa/nixos-config/dark-bg.png";
	in {
	  picture-uri-dark = "file://${dark-bg}";
	};
      };
    }
  ];

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  #services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jaysa = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    packages = with pkgs; [
      tree
      kitty
      kitty-themes
      lsd
    ];
  };

  programs.tmux.enable = true;
  
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ls = "lsd";
      lt = "lsd --tree";
      update = "sudo nixos-rebuild switch";
      edit = "nvim ~/nixos-config/configuration.nix";
    };

    promptInit = ''
      autoload -Uz vcs_info
      zstyle ':vcs_info:*' enable git svn
      zstyle ':vcs_info:git*' formats "- (%b)"
      precmd() {
        vcs_info
      }
      setopt prompt_subst
      prompt='%F{yellow}%n@%m%f %F{red}%~%f %F{yellow}>%f ' 

    '';
    shellInit = "
      kitten themes --reload-in=all 'Gruvbox Dark'
    ";
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = ''
        set background=dark
	colorscheme gruvbox
	set number
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [ 
	  gruvbox 
	  neo-tree-nvim
	  nvim-web-devicons #neotree optional
	  nvim-window-picker #neotree optional
	  plenary-nvim #neotree dependency
	  nui-nvim #neotree dependency
	  nvim-treesitter
	  nvim-treesitter-parsers.yaml
	  nvim-treesitter-parsers.rust
	  nvim-treesitter-parsers.python
	  nvim-treesitter-parsers.puppet
	  nvim-treesitter-parsers.nix
	  nvim-treesitter-parsers.javascript
	  nvim-treesitter-parsers.java
	  nvim-treesitter-parsers.c
	  nvim-treesitter-parsers.markdown
	  nvim-treesitter-parsers.markdown_inline
	  nvim-treesitter-parsers.markdown_inline
	  nvim-treesitter-parsers.html
	  nvim-treesitter-parsers.css
	];
      };
    };
    viAlias = true;
    vimAlias = true;
  };

  programs.firefox = {
    enable = true;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableAccounts = true;
      OverrideFirstRunPage = "";
      OverridePostUpdatePage = "";
      DontCheckDefaultBrowser = true;
      DisplayBookmarksToolbar = "newtab";
      Homepage = {
        URL = "https://jaysa.net";
      };
      ExtensionSettings = {
        #"*".installation_mode = "blocked"; # blocks all addons except the ones specified below
        # uBlock Origin:
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        # Tabby cat
        "{f7f203e0-9d1d-4557-891f-9865877c5b48}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/tabby-cat-friend/latest.xpi";
          installation_mode = "force_installed";
        };
        # gruvbox theme
        "{08d5243b-4236-4a27-984b-1ded22ce01c3}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/gruvboxgruvboxgruvboxgruvboxgr/latest.xpi";
          installation_mode = "force_installed";
        };
        "sponsorBlocker@ajay.app" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/sponsorblock/latest.xpi";
          installation_mode = "force_installed";
        };
	# bitwarden
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
	"Google_AI_Overviews_Blocker@zachbarnes.dev" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/hide-google-ai-overviews/latest.xpi";
          installation_mode = "force_installed";
	};
      };
      Preferences = {
        "browser.contentblocking.category" = { Value = "strict"; Status = "locked"; };
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    git
    pciutils
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

