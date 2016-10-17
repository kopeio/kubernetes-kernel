VERSION=4.4.25

prereqs:
	sudo apt-get update
	sudo apt-get install --yes git vim
	sudo apt-get install --yes equivs

docker: prereqs
	sudo apt-get install --yes apt-transport-https ca-certificates
	echo "deb https://apt.dockerproject.org/repo debian-jessie main" | sudo tee /etc/apt/sources.list.d/docker.list
	sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	sudo apt-get update
	sudo apt-get install --yes docker-engine
	sudo service docker start
	sudo adduser ${USER} docker


# Build kernel
kernel: docker
	cd ~/ && git clone https://github.com/kopeio/kubernetes-kernel.git
	cd ~/kubernetes-kernel/buildkernel && ./build.sh ${VERSION}

# Build metapackages
metapackages: prereqs
	cd ~/kubernetes-kernel/src/meta && equivs-build linux-image-k8s
	cd ~/kubernetes-kernel/metapackages && equivs-build linux-headers-k8s

# Upload
upload: metapackages kernel
	gpg --import ~/secretkey.txt
	sudo apt-get install --yes reprepro
	aws s3 sync s3://dist.kope.io/apt/ ~/kubernetes-kernel/repos/apt/
	cd ~/kubernetes-kernel/repos/apt/ && reprepro includedeb jessie ~/kubernetes-kernel/buildkernel/dist/*/*.deb
	cd ~/kubernetes-kernel/repos/apt/ && reprepro includedeb jessie ~/kubernetes-kernel/buildkernel/dist/*/*.dsc
	cd ~/kubernetes-kernel/repos/apt/ && reprepro includedeb jessie ~/kubernetes-kernel/buildkernel/src/meta/*/*.deb
	gpg --armor --output kopeio.gpg.key --export FBD93F29
	aws s3 cp --acl=public-read kopeio.gpg.key s3://dist-kope-io/apt/kopeio.gpg.key
	aws s3 sync --acl=public-read ~/kubernetes-kernel/repos/apt/pool/ s3://dist.kope.io/apt/pool/
	aws s3 sync --acl=public-read ~/kubernetes-kernel/repos/apt/dists/ s3://dist.kope.io/apt/dists/
	# Not clear if these are actually private or not
	aws s3 sync --acl=private ~/kubernetes-kernel/repos/apt/db/ s3://dist.kope.io/apt/db/
	aws s3 sync --acl=private ~/kubernetes-kernel/repos/apt/conf/ s3://dist.kope.io/apt/conf/

