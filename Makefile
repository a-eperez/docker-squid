default: docker_build

docker_build:
	@docker build \
	--build-arg VCS_REF=`git rev-parse --short HEAD` \
	--build-arg SQUID_MAJOR_VERSION="4" \
	--build-arg SQUID_MENOR_VERSION="6"
	--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` .
