.PHONY: docker-build docker-clean docker-push-registry version

ENVFILE?=.env
ifeq ($(shell test -e $(ENVFILE) && echo -n yes),yes)
	include ${ENVFILE}
	export
endif

DOCKER_REGISTRY?=registry.ftven.net
DOCKER_IMG_NAME?=media-cloud-ai/nginx_vod_module
ifneq ($(DOCKER_REGISTRY), ) 
	DOCKER_IMG_NAME := /${DOCKER_IMG_NAME}
endif
VERSION=nginx-1.17.4-vod-1.25

docker-build:
	@docker build -t ${DOCKER_REGISTRY}${DOCKER_IMG_NAME}:${VERSION} .
	@docker tag ${DOCKER_REGISTRY}${DOCKER_IMG_NAME}:${VERSION} ${DOCKER_REGISTRY}${DOCKER_IMG_NAME}:${CI_COMMIT_SHORT_SHA}

docker-clean:
	@docker rmi ${DOCKER_REGISTRY}${DOCKER_IMG_NAME}:${VERSION}
	@docker rmi ${DOCKER_REGISTRY}${DOCKER_IMG_NAME}:${CI_COMMIT_SHORT_SHA}

docker-registry-login:
	@docker login --username "${DOCKER_REGISTRY_LOGIN}" -p"${DOCKER_REGISTRY_PWD}" ${DOCKER_REGISTRY}
	
docker-push-registry:
	@docker push ${DOCKER_REGISTRY}${DOCKER_IMG_NAME}:${VERSION}
	@docker push ${DOCKER_REGISTRY}${DOCKER_IMG_NAME}:${CI_COMMIT_SHORT_SHA}

version:
	@echo ${VERSION}
