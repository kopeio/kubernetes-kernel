FROM debian:jessie

RUN apt-get update
RUN apt-get install --yes git fakeroot build-essential ncurses-dev xz-utils libssl-dev bc wget gnupg2
RUN apt-get --no-install-recommends install --yes kernel-package


ADD . /src

