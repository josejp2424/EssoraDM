#!/bin/bash
# Build dependencies:
# sudo apt install build-essential cmake pkg-config libx11-dev \
# libxft-dev libxrender-dev libxrandr-dev libxmu-dev \
# libfreetype6-dev libjpeg-dev libpng-dev zlib1g-dev \
# libpam0g-dev libcrypt-dev

set -e

APP="essoradm"
VERSION="1.0-2"
ARCH="$(dpkg --print-architecture 2>/dev/null || echo amd64)"

BASE_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$BASE_DIR/build"
OUT_DIR="$BASE_DIR/${APP}_${VERSION}_${ARCH}"
PKG_DIR="$OUT_DIR/pkgroot"

rm -rf "$BUILD_DIR" "$OUT_DIR"

mkdir -p "$BUILD_DIR"
mkdir -p "$PKG_DIR"

cd "$BUILD_DIR"

if ! pkg-config --exists x11 xft xrender xrandr xmu freetype2 libpng zlib; then
    echo
    echo "WARNING: build dependencies may be missing."
    echo
    echo "Install on Devuan/Debian:"
    echo
    echo "sudo apt install build-essential cmake pkg-config \\"
    echo "libx11-dev libxft-dev libxrender-dev libxrandr-dev \\"
    echo "libxmu-dev libfreetype6-dev libjpeg-dev \\"
    echo "libpng-dev zlib1g-dev libpam0g-dev libcrypt-dev"
    echo
fi

cmake "$BASE_DIR" \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DSYSCONFDIR=/etc \
    -DUSE_PAM=yes \
    -DBUILD_SHARED_LIBS=OFF

make -j"$(nproc)"

make DESTDIR="$PKG_DIR" install

mkdir -p "$PKG_DIR/etc/essoradm"
mkdir -p "$PKG_DIR/usr/share/doc/essoradm"
mkdir -p "$PKG_DIR/DEBIAN"
mkdir -p "$PKG_DIR/etc/pam.d"
mkdir -p "$PKG_DIR/etc/essora-init.d"

cp "$BASE_DIR/hooks/pre-start" "$PKG_DIR/etc/essoradm/pre-start"
cp "$BASE_DIR/hooks/pre-login" "$PKG_DIR/etc/essoradm/pre-login"

chmod 755 \
"$PKG_DIR/etc/essoradm/pre-start" \
"$PKG_DIR/etc/essoradm/pre-login"

# Install Essora-init files directly
if [ -d "$BASE_DIR/assets/essora-init" ]; then

    mkdir -p "$PKG_DIR/usr/local/bin"
    mkdir -p "$PKG_DIR/usr/local/autologin"
    mkdir -p "$PKG_DIR/usr/share/applications"
    mkdir -p "$PKG_DIR/usr/share/essora-init"
    mkdir -p "$PKG_DIR/etc/essora-init.d"

    if [ -d "$BASE_DIR/assets/essora-init/usr/local/bin" ]; then

        cp -a \
        "$BASE_DIR/assets/essora-init/usr/local/bin/." \
        "$PKG_DIR/usr/local/bin/"

        chmod 755 "$PKG_DIR/usr/local/bin/"* \
        2>/dev/null || true
    fi
    if [ -d "$BASE_DIR/assets/essora-init/usr/local/autologin" ]; then

        cp -a \
        "$BASE_DIR/assets/essora-init/usr/local/autologin/." \
        "$PKG_DIR/usr/local/autologin/"

        chmod 755 "$PKG_DIR/usr/local/autologin/"* \
        2>/dev/null || true
    fi

    if [ -d "$BASE_DIR/assets/essora-init/usr/share/applications" ]; then

        cp -a \
        "$BASE_DIR/assets/essora-init/usr/share/applications/." \
        "$PKG_DIR/usr/share/applications/"
    fi

    if [ -d "$BASE_DIR/assets/essora-init/usr/share/essora-init" ]; then

        cp -a \
        "$BASE_DIR/assets/essora-init/usr/share/essora-init/." \
        "$PKG_DIR/usr/share/essora-init/"
    fi

    if [ -d "$BASE_DIR/assets/essora-init/etc/essora-init.d" ]; then

        cp -a \
        "$BASE_DIR/assets/essora-init/etc/essora-init.d/." \
        "$PKG_DIR/etc/essora-init.d/"
    fi
fi

[ -f "$BASE_DIR/COPYING" ] && \
cp "$BASE_DIR/COPYING" \
"$PKG_DIR/usr/share/doc/essoradm/LICENSE.SLIM.GPL2"

[ -f "$BASE_DIR/README" ] && \
cp "$BASE_DIR/README" \
"$PKG_DIR/usr/share/doc/essoradm/README"

[ -f "$BASE_DIR/ChangeLog" ] && \
cp "$BASE_DIR/ChangeLog" \
"$PKG_DIR/usr/share/doc/essoradm/ChangeLog.SLIM"

cat > "$PKG_DIR/usr/share/doc/essoradm/CREDITS" <<EOF
EssoraDM is derived from Slim Display Manager.

Original Slim authors and contributors retain copyright
for upstream code.

EssoraDM modifications and integration:
josejp2424 / Essora

License:
GPL-2.0
EOF

cat > "$PKG_DIR/etc/pam.d/essoradm" <<EOF
#%PAM-1.0
auth       include      common-auth
account    include      common-account
password   include      common-password
session    include      common-session
EOF

cat > "$PKG_DIR/etc/essora-init.d/essoradm" <<EOF
type = bgprocess
command = /usr/bin/essoradm -d
pid-file = /run/essoradm.pid
depends-on = dbus
depends-on = x11-common
restart = false
smooth-recovery = true
EOF

sed "s/^Architecture:.*/Architecture: $ARCH/" \
"$BASE_DIR/debian/control" \
> "$PKG_DIR/DEBIAN/control"

cp "$BASE_DIR/debian/postinst" \
"$PKG_DIR/DEBIAN/postinst"

chmod 755 "$PKG_DIR/DEBIAN/postinst"

cat > "$OUT_DIR/create-package.sh" <<EOF
#!/bin/bash
set -e

cd "\$(dirname "\$0")"

dpkg-deb --build pkgroot ../${APP}_${VERSION}_${ARCH}.deb

echo
echo "Package created:"
echo "../${APP}_${VERSION}_${ARCH}.deb"
echo
EOF

chmod +x "$OUT_DIR/create-package.sh"

echo
echo "OK: compiled successfully:"
echo "$OUT_DIR"
echo
echo "To create the package:"
echo
echo "cd \"$OUT_DIR\""
echo "./create-package.sh"
echo
