# Kubernetes optimized kernel

This is a 4.4 kernel built for running kubernetes.

Currently it only builds a Debian kernel.

It has the following changes:

* 4.4 kernel
* cgroup memory controller is enabled


## Building

If you are going to be signing packages, make sure the gpg key is available using e.g.

```
gpg --import ~/secretkey.txt
```

Check out the code into ~: `cd ~; git clone https://github.com/kopeio/kubernetes-kernel.git`

Then build the kernel image:

```
cd ~/kubernetes-kernel; make upload-kernel
```

Then update & validate the kernel.

When you are ready to make this the new kernel, upload the metapackages:

```
cd ~/kubernetes-kernel; make upload-metapackages
```
