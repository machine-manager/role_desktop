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
		# We install xfce4-mixer even though it brings in streamer0.10 packages
		# because it includes the volume control for the panel, and because
		# alsamixer and alsamixergui are bad in different ways (alsamixer is
		# white-on-black; alsamixergui doesn't scale on hidpi).
		base_desktop_packages = [
			"xorg",
			"alsa-base",
			"alsa-utils",
			"gnome-themes-standard",   # includes the adwaita engine
			"adwaita-icon-theme",
			"dmz-cursor-theme",
			"roxterm",
			"xterm",                   # backup terminal in case roxterm is broken
			"xfwm4",
			"xfconf",
			"xfdesktop4",
			"xfce4-battery-plugin",
			"xfce4-mixer",
			"xfce4-notifyd",
			"xfce4-panel",
			"xfce4-power-manager",
			"xfce4-screenshooter",
			"xfce4-session",
			"xfce4-settings",
			"xfce4-volumed",
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
