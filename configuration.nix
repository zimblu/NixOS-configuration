# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
let
  # These variable names are used by Aegis backend
  version = "23.11"; #or 23.11 or 23.05
  username = "athena";
  hashed = "$6$JdQs9FOUuLr.iKlI$Mu5IQdeqcGwXvRNEtS6UroWftY3/tmRrbQN3Fh71mqB0bwQIQSXDMS8mrwfvp9/jiQtNhxlkbgky4uUq9UVjE.";
  hashedRoot = "$6$MNME0GCtW/GWl.3s$VzJmHETt4jWTrw90HGtcL/Lbt4kCSKvBwFncJ1k8MPdu0N1rVbD.V4uwH2oxbWWFwMlYXtyhrPVoN9CO2WGTN0";
  hostname = "athenaos";
  theme = "graphite";
  desktop = "gnome";
  dmanager = "gdm";
  shell = "fish";
  terminal = "kitty";
  browser = "firefox";
  bootloader = "systemd";
  hm-version = if version == "unstable" then "master" else "release-23.11"; # "master" or "release-23.11"; # Correspond to home-manager GitHub branches
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/${hm-version}.tar.gz";
in
{
	networking.enableIPv6 = false;
  	services.flatpak.enable = true;
  
    	#nix.settings.substituters = ["https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"];
    	nixpkgs.config = {
        	# 可以安装不开源软件例如 nvidia 官方驱动，必须开启
        	allowUnfree = true;
        	# 开启 unstable 支持 systemPackages 里可以 unstable.vscode 安装最新版 vscode
        	packageOverrides = pkgs: {
            		unstable = import <nixos-unstable> {
                	config = config.nixpkgs.config;
            		};
        	};
    	};
  imports =
    [ # Include the results of the hardware scan.
      {
        _module.args.version = version;
        _module.args.username = username;
        _module.args.hashed = hashed;
        _module.args.hashedRoot = hashedRoot;
        _module.args.hostname = hostname;
        _module.args.theme = theme;
        _module.args.desktop = desktop;
        _module.args.dmanager = dmanager;
        _module.args.shell = shell;
        _module.args.terminal = terminal;
        _module.args.browser = browser;
        _module.args.bootloader = bootloader;
      }
      (import "${home-manager}/nixos")
      /etc/nixos/hardware-configuration.nix
      ./modules/boot/${bootloader}
      ./modules/dms/${dmanager}
      ./modules/themes/${theme}
      ./home-manager/desktops/${desktop}
      ./home-manager/terminals/${terminal}
      ./home-manager/browsers/${browser}
      ./home-manager/shells/${shell}
      ./hosts/software
      ./.

    ];
 

    environment = {
        systemPackages = with pkgs; [
            # 系统安装一些必须工具
            # vim
            # curl
            # git
	    libgcc
	    gcc
        ];
    };
        # 安装一些字体
	fonts = {
        fontDir.enable = true;
        packages = with pkgs; [
            noto-fonts
            source-code-pro
            source-han-sans
            source-han-serif
            sarasa-gothic
        ];
        # 设置 fontconfig 防止出现乱码
        fontconfig = {
            defaultFonts = {
                emoji = [
                    "Noto Color Emoji"
                ];
                monospace = [
                    "Noto Sans Mono CJK SC"
                    "Sarasa Mono SC"
                    "DejaVu Sans Mono"
                ];
                sansSerif = [
                    "Noto Sans CJK SC"
                    "Source Han Sans SC"
                    "DejaVu Sans"
                ];
                serif = [
                    "Noto Serif CJK SC"
                    "Source Han Serif SC"
                    "DejaVu Serif"
                ];
            };
        };
    };
    # 设置 locale 默认值为 zh
    #i18n.defaultLocale="zh_CN.UTF-8";

    # 输入法引擎使用 ibus，输入法使用 rime
    i18n.inputMethod = {
        enabled = "fcitx5";
	fcitx5.addons = with pkgs; [ fcitx5-m17n fcitx5-chewing fcitx5-chinese-addons ];
    };
}
