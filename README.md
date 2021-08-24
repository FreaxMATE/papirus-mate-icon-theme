# papirus-mate-icon-theme

a green folder color variant of the papirus icon theme to match the MATE green color.


### Installation

Use the scripts to install the latest version directly from this repo (independently of your distro):

**NOTE:** Use the same script to update icon themes.

#### ROOT directory (recommended)

```
wget -qO- https://raw.githubusercontent.com/FreaxMATE/papirus-mate-icon-theme/main/install.sh | sh
```

#### HOME directory for GTK

```
wget -qO- https://raw.githubusercontent.com/FreaxMATE/papirus-mate-icon-theme/main/install.sh | DESTDIR="$HOME/.icons" sh
```

#### \*BSD systems

```
wget -qO- https://raw.githubusercontent.com/FreaxMATE/papirus-mate-icon-theme/main/install.sh | env DESTDIR="/usr/local/share/icons" sh
```

### Build

#### From scratch

```sh
git clone --recursive https://github.com/FreaxMATE/papirus-mate-icon-theme.git
cd papirus-mate-icon-theme
./build.sh
```

#### From existing local repo

```sh
cd papirus-mate-icon-theme
git pull
git submodule foreach git pull
./build.sh
```
