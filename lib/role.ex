alias Converge.{Util, All}

defmodule RoleDesktop do
	require Util
	import Util, only: [conf_dir: 1, conf_file: 1]
	Util.declare_external_resources("files")

	def role(tags \\ []) do
		release = Util.tag_value!(tags, "release") |> String.to_atom()
		# We list specific xfce4 packages here instead of "xfce4", which would
		# install some packages we don't want:
		# orage                   - we use a spreadsheet for a calendar
		# xfce4-pulseaudio-plugin - we don't use pulseaudio
		# xfce4-appfinder         - we use a popup terminal and whiskermenu instead
		# libxfce4ui-utils        - we don't need the xfce4 about screen
		# thunar                  - we use the command line for file management
		#
		# We don't install xfce4-indicator-plugin because it brings in upstart
		# and mountall, and apparently we have no need for it because xfce4-panel
		# includes built-in support for the notification area via
		# /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins/libsystray.so
		#
		# We don't install xfce4-volumed because it's no longer maintained (and
		# it doesn't really work).
		base_desktop_packages = [
			"xorg",
			"alsa-utils",              # alsamixer, amixer
			"gnome-themes-standard",   # includes the adwaita engine
			"gtk2-engines-pixbuf",     # necessary for the adwaita theme to render correctly
			"dmz-cursor-theme",        # the cursor theme we use
			"dolphin",                 # nautilus is bad: sometimes stops generating thumbnails in big folders, thumbnails have way too much padding
			"kio-extras",              # for dolphin to show thumbnails
			"kio-mtp",                 # for dolphin to access to mobile devices
			"systemsettings",          # for configuring KDE to show icons in dolphin: comment #28 https://bugs.launchpad.net/ubuntu/+source/dolphin/+bug/1509562
			"kde-config-gtk-style",    # for Qt5 apps to look like GTK apps
			"xterm",                   # backup terminal emulator in case the primary one breaks
			"xclip",                   # for manipulating clipboard over ssh
			"xfwm4",
			"xfconf",
			"xfdesktop4",
			"xfce4-battery-plugin",
			"xfce4-notifyd",
			"xfce4-panel",
			"xfce4-power-manager",
			"xfce4-screenshooter",
			"xfce4-session",
			"xfce4-settings",
			"xfce4-whiskermenu-plugin",
		] ++ (
			if release == :xenial do
				[
					"roxterm",
					"adwaita-icon-theme-full",
					"elementary-icon-theme", # icons that will actually show up in dolphin
					"alsa-base",
					"libqt5libqgtk2",        # for Qt5 apps to look like GTK apps
				]
			else
				[
					# roxterm is discontinued and not in stretch; gnome-terminal is slower
					# than konsole and can't open tabs to the right of the current tab
					"konsole",
					"adwaita-icon-theme",
					"nuvola-icon-theme",     # icons that will actually show up in dolphin
					"qt5-gtk-platformtheme", # for Qt5 apps to look like GTK apps
				]
			end
		)
		general_font_packages = [
			"fonts-windows",
			"fonts-macos",
			"fonts-roboto",
			"fonts-pragmatapro-mono",
			"fonts-noto-hinted",
			"fonts-noto-cjk",
			"fonts-san-francisco",
			"fonts-source-sans-pro",
		]
		development_packages = [
			"git",
			"git-man",
			"git-svn",
			"patch",
			"manpages",
			"info",       # for reading documentation for GNU utilities
			"colordiff",
			"devscripts",
			"wdiff",
			"unzip",
			"zip",
			"p7zip-full",
			"p7zip-rar",
		] ++ (
			# stretch is missing git-remote-hg
			if release == :stretch, do: [], else: ["git-remote-hg"]
		)
		more_packages = [
			"google-chrome-stable",
			# For running AppImages, which apparently require FUSE
			"fuse",
		]
		desired_packages = \
			base_desktop_packages ++ general_font_packages ++ development_packages ++ more_packages
		undesired_packages = [
			# We use our own fonts-windows instead
			"ttf-mscorefonts-installer",
			# We use ALSA instead
			"pulseaudio",
			# We just allow desktop users to nice down to -11
			# in /etc/security/limits.conf (TODO)
			"rtkit",
			# Annoying program that pops up a little window asking for a password
			# (and putting the keyboard into secure mode!) when you actually
			# wanted the ssh connection to fail.
			"ssh-askpass",
			# xserver-xorg has a Depends on `xserver-xorg-input-all | xorg-driver-input`
			# but we don't need support for all input devices.
			"xserver-xorg-input-all",
		]
		post_install_unit = %All{units: [
			conf_file("/etc/skel/.xinitrc"),

			conf_dir("/etc/skel/.config"),

			conf_file("/etc/skel/.config/Trolltech.conf"),

			conf_dir("/etc/skel/.config/xfce4"),
			conf_dir("/etc/skel/.config/xfce4/xfconf"),
			conf_dir("/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml"),
			conf_file("/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml"),
			conf_file("/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml"),
			conf_file("/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-panel.xml"),
			conf_file("/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-notifyd.xml"),
			conf_file("/etc/skel/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml"),
			conf_dir("/etc/skel/.config/xfce4/panel"),
			conf_file("/etc/skel/.config/xfce4/panel/whiskermenu-7.rc"),

			conf_dir("/etc/skel/.config/roxterm.sourceforge.net"),
			conf_dir("/etc/skel/.config/roxterm.sourceforge.net/Colours"),
			conf_file("/etc/skel/.config/roxterm.sourceforge.net/Colours/Tango"),
			conf_file("/etc/skel/.config/roxterm.sourceforge.net/Colours/Default"),
			conf_file("/etc/skel/.config/roxterm.sourceforge.net/Colours/GTK"),
			conf_file("/etc/skel/.config/roxterm.sourceforge.net/Global"),
			conf_dir("/etc/skel/.config/roxterm.sourceforge.net/Shortcuts"),
			conf_file("/etc/skel/.config/roxterm.sourceforge.net/Shortcuts/Default"),
			conf_dir("/etc/skel/.config/roxterm.sourceforge.net/Profiles"),
			conf_file("/etc/skel/.config/roxterm.sourceforge.net/Profiles/Default"),
		]}
		%{
			implied_roles:      [RoleGoogleChromeRepo, RoleCustomPackages],
			desired_packages:   desired_packages,
			undesired_packages: undesired_packages,
			post_install_unit:  post_install_unit,
			ferm_output_chain:
				"""
				# Avahi (?) tries to talk mDNS on all interfaces; we don't want to log it
				daddr 224.0.0.251 REJECT;

				# Chrome tries to talk UPnP on all interfaces (probably for Chromecast); we don't want to log it
				daddr 239.255.255.250 proto udp dport 1900 REJECT;

				outerface lo {
					# Chrome Developer Tools, when opened, repeatedly tries to
					# connect to this; we don't want to log it.  Implemented in
					# chrome/browser/devtools/device/devtools_android_bridge.cc
					daddr 127.0.0.1 proto tcp syn dport 9229 REJECT;
				}
				""",
		}
	end
end
