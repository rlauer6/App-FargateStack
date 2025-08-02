#-*- mode: makefile; -*-

SHELL := /bin/bash
.SHELLFLAGS := -ec

.PHONY: all check-env helloworld http-test

all: check-env README.md

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
	docker rmi helo

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
	docker build -f $< . -t $$(basename $@ .id) | grep 'Successfully built' | awk '{print $$3}' > $@

helloworld: helloworld.id

########################################################################
# HTTP service image
########################################################################

HTTP_TEST_DEPS = \
    Dockerfile.apache \
    00-default.conf \
    apache2.conf \
    http-test.repo

http-test: http-test.id

http-test.id: $(HTTP_TEST_DEPS)
	docker build -f $< . -t $$(basename $@ .id) | grep 'Successfully built' | awk '{print $$3}' > $@

install: http-test.id helloworld.id
	@helloworld_digest=$$(aws ecr describe-images \
	  --repository-name helloworld \
	  --query 'sort_by(imageDetails,&imagePushedAt)[-1].imageDigest' \
	  --output text --profile $$AWS_PROFILE); \
	if ! [ -s helloworld.digest ] || [ "$$helloworld_digest" != "$$(cat helloworld.digest)" ]; then \
	  echo "Updating ECR image for helloworld..."; \
	  cat helloworld.digest; \
	  echo "$$helloworld_digest"; \
	  ./deploy-to-ecr helloworld:latest | grep '^latest' | awk '{print $$3}' > helloworld.digest; \
	else \
	  echo "helloworld ECR image is up-to-date."; \
	fi
	@http_test_digest=$$(aws ecr describe-images \
	  --repository-name http-test \
	  --query 'sort_by(imageDetails,&imagePushedAt)[-1].imageDigest' \
	  --output text --profile $$AWS_PROFILE); \
	if ! [ -s http-test.digest ] || [ "$$http_test_digest" != "$$(cat http-test.digest)" ]; then \
	  echo "Updating ECR image for http-test..."; \
	  ./deploy-to-ecr http-test:latest | grep '^latest' | awk '{print $$3}' > http-test.digest; \
	else \
	  echo "http-test ECR image is up-to-date."; \
	fi
