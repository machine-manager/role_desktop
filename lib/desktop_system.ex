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

	def configure(_opts \\ []) do
		extra_repositories = MapSet.new([
			:custom_packages_local,
			:google_chrome,
			:oracle_virtualbox,
			:graphics_drivers_ppa,
			:wine_ppa,
		])
		xfce4_packages = ~w(
			xfce4-battery-plugin xfce4-mixer xfce4-notifyd xfce4-panel xfce4-power-manager
			xfce4-screenshooter xfce4-session xfce4-settings xfce4-volumed xfce4-whiskermenu-plugin
		)
		# TODO: most of this should be in ivan_desktop, not desktop_system
		wine_packages = [
			"wine-staging",
			# Use wine-staging as the default wine (/usr/bin/wine)
			"winehq-staging",
			"winetricks",
		]
		general_font_packages = ~w(
			fonts-windows fonts-macos fonts-roboto fonts-pragmatapro-mono
			fonts-san-francisco-display fonts-source-sans-pro
		)
		# XXXX TODO More fonts; Used in Anki for practicing kanji reading in multiple fonts
		japanese_font_packages = ~w(
			fonts-dejima-mincho
		)
		desktop_automation_packages = ~w(
			xbindkeys xautomation xdotool xsnap easystroke
		)
		development_packages = ~w(
			manpages colordiff git git-man git-remote-hg git-svn
		)
		more_packages = ~w(
			google-chrome-stable firefox hexchat roxterm libreoffice-calc mpv
			redshift anki tagainijisho
		)
		extra_packages = \
			xfce4_packages ++ wine_packages ++ general_font_packages ++ \
			japanese_font_packages ++ desktop_automation_packages ++ \
			development_packages ++ more_packages
		BaseSystem.Configure.configure(
			extra_repositories: extra_repositories,
			extra_packages:     extra_packages
		)
		# TODO: PackagePurged pulseaudio
		# TODO: PackagePurged rtkit
	end
end
