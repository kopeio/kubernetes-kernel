FROM debian:sid

RUN apt-get update
RUN apt-get install --yes git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc wget gnupg2
RUN apt-get --no-install-recommends install --yes kernel-package

# Deps for building perf-tools
RUN apt-get install --yes libaudit-dev libslang2-dev libelf-dev libdw-dev libnuma-dev libunwind-dev libperl-dev libiberty-dev \
     asciidoc binutils-dev flex bison \
     python-dev libgtk2.0-dev rename

ADD . /src

