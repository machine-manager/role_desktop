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
		xfce4_packages = ~w(
			xfce4-battery-plugin
			xfce4-mixer
			xfce4-notifyd
			xfce4-panel
			xfce4-power-manager
			xfce4-screenshooter
			xfce4-session
			xfce4-settings
			xfce4-volumed
			xfce4-whiskermenu-plugin
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
			manpages
			colordiff
			git
			git-man
			git-remote-hg
			git-svn
		)
		more_packages = ~w(
			google-chrome-stable
		)
		extra_packages = \
			xfce4_packages ++ general_font_packages ++ development_packages ++ more_packages
		BaseSystem.Configure.configure(
			repositories:   repositories,
			extra_packages: extra_packages
		)
		# TODO: PackagePurged pulseaudio
		# TODO: PackagePurged rtkit
	end
end
