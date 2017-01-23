alias Converge.Util

defmodule DesktopSystem.Configure do
	@moduledoc """
	Converts a `debootstrap --variant=minbase` install of Ubuntu LTS into a
	useful Ubuntu desktop.

	Requires that these packages are already installed:
	erlang-base-hipe erlang-crypto curl
	"""
	require Util
	Util.declare_external_resources("files")

	defmacro content(filename) do
		File.read!(filename)
	end

	def main(_args) do
		configure()
	end

	def configure(opts \\ []) do
		repositories = Keyword.get(opts, :repositories) || MapSet.new([
			:custom_packages_remote,
			:google_chrome,
		])
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
			"adwaita-icon-theme",
			"dmz-cursor-theme",
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
		network_manager_packages = ~w(
			network-manager
			network-manager-gnome
			network-manager-openvpn
			network-manager-openvpn-gnome
		)
		general_font_packages = ~w(
			fonts-windows
			fonts-macos
			fonts-roboto
			fonts-pragmatapro-mono
			fonts-noto-hinted
			fonts-noto-cjk
			fonts-san-francisco-display
			fonts-source-sans-pro
		)
		development_packages = ~w(
			git
			git-man
			git-remote-hg
			git-svn
			patch
			manpages
			colordiff
			devscripts
			wdiff
			unzip
			zip
			p7zip-full
		)
		more_packages = ~w(
			google-chrome-stable
		)
		extra_packages = \
			base_desktop_packages ++ network_manager_packages ++ general_font_packages ++ \
			development_packages ++ more_packages
		BaseSystem.Configure.configure(
			repositories:   repositories,
			extra_packages: extra_packages
		)
		# TODO: PackagePurged pulseaudio
		# TODO: PackagePurged rtkit
	end
end
