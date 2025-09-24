#-*- mode: makefile; -*-

SHELL := /bin/bash
.SHELLFLAGS := -ec

.PHONY: all check-env helloworld http-test images

all: check-env README.md

images: helloworld http-test

check-env:
	@if [ -z "$$AWS_PROFILE" ]; then \
	  echo "Environment variable AWS_PROFILE is not set" >&2; \
	  exit 1; \
	fi

README.md: README.md.in
	md-utils.pl $< > $@

.PHONY: clean realclean

clean:
	rm -f README.md

realclean:
	rm -f *.repo *.id
	for a in $$(docker images | grep helloworld | awk '{print $$1}'); do \
	  docker rmi $$a; \
	done;
	for a in $$(docker images | grep http-test | awk '{print $$1}'); do \
	  docker rmi $$a; \
	done;

########################################################################
# pattern rules
########################################################################

%.repo:
	repo=$$(basename $@ .repo); \
	tmpfile=$$(mktemp); \
	aws ecr describe-repositories --profile $$AWS_PROFILE --repository $$repo 2>/dev/null > $$tmpfile; \
	if ! [ -s $$tmpfile ]; then \
	  aws ecr create-repository --repository $$repo --profile $$AWS_PROFILE > $@; \
	else \
	  [ -s $@ ] || mv $$tmpfile $@; \
	fi; \
	rm -f "$$tmpfile"

########################################################################
# Hello World!
########################################################################

HELLOWORLD_DEPS= \
    Dockerfile \
    HelloWorld.pl \
    helloworld.repo

helloworld.id: $(HELLOWORLD_DEPS)
	docker build -f $< . -t $$(basename $@ .id) 2>&1 | tee build-$$(basename $@ .id).log
	grep 'Successfully built' build-$$(basename $@ .id).log | awk '{print $$3}' > $@

helloworld: helloworld.id

########################################################################
# development image
########################################################################

DOCKERHUB_USER = rlauer
PROJECT        = app-fargatestack-dev
IMAGE          = $(PROJECT)
REPO           = $(DOCKERHUB_USER)/$(IMAGE)

$(PROJECT): $(PROJECT).id

$(PROJECT).id: Dockerfile.dev
	docker build -f $< . -t $$(basename $@ .id) 2>&1 | tee build-$$(basename $@ .id).log
	grep 'Successfully built' build-$$(basename $@ .id).log | awk '{print $$3}' > $@

.PHONY: public

public: $(PROJECT).digest

$(PROJECT).digest: $(PROJECT).id
	docker login -u $(DOCKERHUB_USER) --password-stdin < ~/.ssh/dockerhub.token
	docker tag $(IMAGE):latest $(REPO):$(IMAGE); \
<<<<<<< HEAD
	docker push $(REPO):$(IMAGE) | tail -1 | tee | awk '{print $$3}' > $@
=======
	docker push $(REPO):$(IMAGE) | tee /dev/tty | tail -1 | awk '{print $$3}' > $@
>>>>>>> main

########################################################################
# HTTP service image
########################################################################

HTTP_TEST_DEPS = \
    Dockerfile.apache \
    000-default.conf \
    apache2.conf \
    http-test.repo

http-test: http-test.id

http-test.id: $(HTTP_TEST_DEPS)
	docker build -f $< . -t $$(basename $@ .id) 2>&1 | tee build-$$(basename $@ .id).log
	grep 'Successfully built' build-$$(basename $@ .id).log | awk '{print $$3}' > $@

install: http-test.id helloworld.id
	./deploy-to-ecr helloworld:latest | grep '^latest' | awk '{print $$3}' > helloworld.digest
	./deploy-to-ecr http-test:latest | grep '^latest' | awk '{print $$3}' > http-test.digest
