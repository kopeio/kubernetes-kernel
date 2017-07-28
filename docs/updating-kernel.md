## How to update to a new kernel

### Build new package

* Checkout a new git branch
* Edit Makefile `VERSION` with the new version
* Copy latest `buildkernel/src/config-${LATEST_VERSION}` to `buildkernel/src/config-${NEWVERSION}`
* Make any required config changes
* Build and validate, send PR

### Mark new package for use

* Edit `meta/linux-headers-k8s` and `meta/linux-image-k8s` to point to the new version
