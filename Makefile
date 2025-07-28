#-*- mode: makefile; -*-

SHELL := /bin/bash
.SHELLFLAGS := -ec

MODULE_NAME := App::FargateStack
MODULE_PATH := $(subst ::,/,$(MODULE_NAME)).pm

PERL_MODULES = \
    lib/App/Benchmark.pm.in \
    lib/App/Command.pm.in

GPERL_MODULES = $(PERL_MODULES:.pm.in=.pm)

AWS_PERL_MODULES = \
    lib/App/ACM.pm.in \
    lib/App/AWS.pm.in \
    lib/App/EC2.pm.in \
    lib/App/ECR.pm.in \
    lib/App/ECS.pm.in \
    lib/App/EFS.pm.in \
    lib/App/ElbV2.pm.in \
    lib/App/Events.pm.in \
    lib/App/IAM.pm.in \
    lib/App/Logs.pm.in \
    lib/App/Route53.pm.in \
    lib/App/S3Api.pm.in \
    lib/App/SecretsManager.pm.in \
    lib/App/SQS.pm.in \
    lib/App/STS.pm.in \

GAWS_PERL_MODULES = $(AWS_PERL_MODULES:.pm.in=.pm)

VERSION := $(shell cat VERSION)

TARBALL = $(subst ::,-,$(MODULE_NAME))-$(VERSION).tar.gz

all: $(TARBALL)

%.pm: %.pm.in
	rm -f $@
	sed "s/[@]PACKAGE_VERSION[@]/$(VERSION)/g" $< > $@
	perl -wc -I lib $@
	chmod -w $@

FARGATE_BUILDERS = \
    lib/App/FargateStack/Builder.pm.in \
    lib/App/FargateStack/Builder/Certificate.pm.in \
    lib/App/FargateStack/Builder/Cluster.pm.in \
    lib/App/FargateStack/Builder/EFS.pm.in \
    lib/App/FargateStack/Builder/Events.pm.in \
    lib/App/FargateStack/Builder/LogGroup.pm.in \
    lib/App/FargateStack/Builder/HTTPService.pm.in \
    lib/App/FargateStack/Builder/IAM.pm.in \
    lib/App/FargateStack/Builder/SecurityGroup.pm.in \
    lib/App/FargateStack/Builder/Secrets.pm.in \
    lib/App/FargateStack/Builder/Service.pm.in \
    lib/App/FargateStack/Builder/S3Bucket.pm.in \
    lib/App/FargateStack/Builder/SQSQueue.pm.in \
    lib/App/FargateStack/Builder/TaskDefinition.pm.in \
    lib/App/FargateStack/Builder/Utils.pm.in

GFARGATE_BUILDERS = $(FARGATE_BUILDERS:.pm.in=.pm)

$(GFARGATE_BUILDERS):  $(GAWS_PERL_MODULES) lib/App/FargateStack/Constants.pm

FARGATE_DEPS = \
    $(GAWS_PERL_MODULES) \
    lib/App/Benchmark.pm \
    lib/App/FargateStack/Constants.pm \
    $(GFARGATE_BUILDERS)

lib/App/FargateStack.pm: $(FARGATE_DEPS)

lib/App/FargateStack/Builder/IAM.pm: \
    lib/App/FargateStack/Constants.pm \
    $(GAWS_PERL_MODULES) \
    lib/App/FargateStack/Builder/Utils.pm

lib/App/FargateStack/Builder/Events.pm: lib/App/FargateStack/Constants.pm $(GAWS_PERL_MODULES)

$(GAWS_PERL_MODULES): $(AWS_PERL_MODULES) lib/App/Command.pm lib/App/FargateStack/Constants.pm

TARBALL_DEPS = \
    $(GPERL_MODULES) \
    $(GAWS_PERL_MODULES) \
    lib/App/FargateStack.pm \
    requires \
    test-requires \
    README.md

$(TARBALL): buildspec.yml $(TARBALL_DEPS)
	make-cpan-dist.pl -b $<

README.md: lib/$(MODULE_PATH)
	pod2markdown $< > $@

clean:
	find lib -name '*.pm' -exec rm -f {} \;
	rm -f *.tar.gz
	rm -f provides extra-files resources

include version.mk
