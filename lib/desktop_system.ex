alias Converge.{Util, All, FilePresent, DirectoryPresent}

defmodule DesktopSystem.Configure do
	@moduledoc """
	Converts a `debootstrap --variant=minbase` install of Ubuntu LTS into a
	useful Ubuntu desktop.

	Requires that these packages are already installed:
	erlang-base-hipe erlang-crypto curl
	"""
	require Util
	Util.declare_external_resources("files")

	defmacrop conf_dir(p) do
		quote do
			%DirectoryPresent{path: unquote(p), mode: 0o755}
		end
	end

	defmacrop conf_file(p) do
		data = File.read!("files/" <> p)
		quote do
			%FilePresent{path: unquote(p), content: unquote(data), mode: 0o644}
		end
	end

	def main(_args) do
		configure()
	end

	def configure(opts \\ []) do
		repositories = Keyword.get(opts, :repositories) || MapSet.new([
			:custom_packages_remote,
			:google_chrome,
		])
		network_manager = Keyword.get(opts, :network_manager, false)

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
			"alsa-base",
			"alsa-utils",              # alsamixer, amixer
			"gnome-themes-standard",   # includes the adwaita engine
			"gtk2-engines-pixbuf",     # necessary for the adwaita theme to render correctly
			"adwaita-icon-theme",      # the icon theme we use
			"gnome-icon-theme",        # necessary to avoid broken icons when using adwaita icon theme in xfce4
			"dmz-cursor-theme",        # the cursor theme we use
			"roxterm",
			"xterm",                   # backup terminal in case roxterm breaks
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
		]
		network_manager_packages = case network_manager do
			true  -> [
				"network-manager",
				"network-manager-gnome",
				"network-manager-openvpn",
				"network-manager-openvpn-gnome",
			]
			false -> []
		end
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
			"git-remote-hg",
			"git-svn",
			"patch",
			"manpages",
			"colordiff",
			"devscripts",
			"wdiff",
			"unzip",
			"zip",
			"p7zip-full",
		]
		more_packages = [
			"google-chrome-stable",
		]
		extra_packages = \
			base_desktop_packages ++ network_manager_packages ++ general_font_packages ++ \
			development_packages ++ more_packages
		extra_configuration = %All{units: [
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
		BaseSystem.Configure.configure(
			repositories:             repositories,
			extra_packages:           extra_packages,
			extra_configuration:      extra_configuration,
			extra_undesired_packages: [
				# We use our own fonts-windows instead
				"ttf-mscorefonts-installer",
				# We use ALSA instead
				"pulseaudio",
				# We just allow desktop users to nice down to -11
				# in /etc/security/limits.conf (TODO)
				"rtkit",
			],
		)
	end
end
