# EssoraDM

EssoraDM is a lightweight display manager for Essora Linux, originally based on Slim and expanded with new features and deeper integration for modern Essora systems.

EssoraDM goes beyond a simple Slim fork by adding native Essora functionality, custom startup behavior, optional boot splash integration, and a cleaner user experience designed for lightweight environments.

---

## Features

* Lightweight and fast display manager
* Essora branding and theme integration
* Native Essora-init integration
* Optional boot splash support
* Customizable startup hooks
* Automatic user configuration
* Autologin support
* Session selection support
* PAM authentication support
* Low resource usage
* Designed for lightweight desktop environments
* OpenRC compatible environments
* Modernized build and packaging scripts

---

## EssoraDM Hooks

EssoraDM adds startup hooks for system customization:

```text
/etc/essoradm/pre-start
/etc/essoradm/pre-login
```

Examples:

* Show Essora boot splash
* Start custom services
* Configure session variables
* Execute scripts before login

---

## Essora Boot Splash Integration

EssoraDM optionally supports Essora-init boot splash integration.

Included components:

```text
/usr/local/bin/essora-splash
/usr/share/essora-init/splash/essora-boot.png
/etc/essora-init.d/essora-splash
```

Boot sequence example:

```text
Kernel
→ Essora-init
→ Essora Splash
→ EssoraDM
→ Login
→ Desktop
```

---

## Build Dependencies

Install dependencies on Devuan/Debian:

```bash
sudo apt install build-essential cmake pkg-config \
libx11-dev libxft-dev libxrender-dev \
libxrandr-dev libxmu-dev libfreetype6-dev \
libjpeg-dev libpng-dev zlib1g-dev \
libpam0g-dev libcrypt-dev
```

---

## Building

Compile:

```bash
./build-essoradm.sh
```

Create package:

```bash
cd essoradm_VERSION_ARCH
./create-package.sh
```

---

## License

EssoraDM is derived from Slim Display Manager.

Original Slim authors and contributors retain copyright
for upstream code.

EssoraDM modifications and integration:

Copyright (C) 2026 josejp2424

License: GNU General Public License v2.0

