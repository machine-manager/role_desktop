alias Converge.{Util, All}

defmodule RoleDesktop do
	require Util
	import Util, only: [conf_dir: 1, conf_file: 1]
	Util.declare_external_resources("files")

	def role(_tags \\ []) do
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
			"xserver-xorg-input-evdev", # for regular mice
			"xinput",                   # for tweaking mouse acceleration
			"alsa-utils",               # alsamixer, amixer
			"gnome-themes-standard",    # includes the adwaita engine
			"gtk2-engines-pixbuf",      # necessary for the adwaita theme to render correctly
			"dmz-cursor-theme",         # the cursor theme we use
			# Use dolphin because nautilus is bad: it sometimes stops generating thumbnails
			# in big folders; thumbnails have way too much padding.
			#
			# Note: for dolphin to show thumbnails for images, check
			# View -> Adjust View Properties... -> [x] Show preview
			"dolphin",
			"kio-extras",               # for dolphin to show thumbnails
			"kio-mtp",                  # for dolphin to access to mobile devices
			"systemsettings",           # for configuring KDE to show icons in dolphin: comment #28 https://bugs.launchpad.net/ubuntu/+source/dolphin/+bug/1509562
			"kde-config-gtk-style",     # for Qt5 apps to look like GTK apps
			# Fix this warning:
			# ** (konsole:5943): WARNING **: Error retrieving accessibility bus
			# address: org.freedesktop.DBus.Error.ServiceUnknown: The name
			# org.a11y.Bus was not provided by any .service files
			"at-spi2-core",
			"xterm",                    # backup terminal emulator in case the primary one breaks
			"xclip",                    # for manipulating clipboard over ssh
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
			# roxterm is discontinued and not in stretch; gnome-terminal is slower
			# than konsole and can't open tabs to the right of the current tab
			"konsole",
			"adwaita-icon-theme",
			"nuvola-icon-theme",     # icons that will actually show up in dolphin
			"qt5-gtk-platformtheme", # for Qt5 apps to look like GTK apps
		]
		general_font_packages = [
			"fonts-roboto",
			"fonts-noto-hinted",
			"fonts-noto-cjk",
			"fonts-noto-cjk-extra",
		]
		development_packages = [
			"git",
			"git-man",
			"git-svn",
			"patch",
			"colordiff",
			"devscripts",
			"wdiff",
			"zip",
			"p7zip-full",
			"p7zip-rar",
		]
		desired_packages = \
			base_desktop_packages ++ general_font_packages ++ development_packages
		undesired_packages = [
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
			# Worse than synaptics for touchpads; use evdev for regular mice
			"xserver-xorg-input-libinput",
			# We don't need all video drivers
			"xserver-xorg-video-all",
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
			desired_packages:   desired_packages,
			undesired_packages: undesired_packages,
			post_install_unit:  post_install_unit,
			ferm_output_chain:
				"""
				# Avahi (?) tries to talk mDNS on all interfaces; we don't want to log it
				daddr 224.0.0.251 REJECT;
				""",
		}
	end
end
