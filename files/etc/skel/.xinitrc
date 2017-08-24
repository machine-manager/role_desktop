export QT_IM_MODULE=ibus

# XDG_CURRENT_DESKTOP=GNOME to get fonts that aren't too small in Qt5 apps
# https://wiki.archlinux.org/index.php/qt#Configuration_of_Qt5_apps_under_environments_other_than_KDE
export XDG_CURRENT_DESKTOP=GNOME

# Make sure mouse acceleration is disabled
xset m 0 0

exec xfce4-session
