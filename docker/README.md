# Table of Contents

* [Docker Test Images for App::FargateStack](#docker-test-images-for-appfargatestack)
  * [Requirements](#requirements)
  * [Markdown Utility](#markdown-utility)
* [Building Components](#building-components)
* [Deploying the Test Images](#deploying-the-test-images)
* [Cleaning Up and Forcing Rebuilds](#cleaning-up-and-forcing-rebuilds)

# Docker Test Images for App::FargateStack

This directory contains a `Makefile` for building Docker images that
can be pushed to Amazon ECR. These images are used to test the
`App::FargateStack` framework.

## Requirements

- `make`
- [`md-utils.pl`](https://github.com/rlauer6/markdown.git)
- `docker`

## Markdown Utility

To build the `README` install `md-utils.pl` from CPAN.
The `Makefile` uses the `md-utils.pl` script to render markdown from
pod.

```
curl -L https://cpanmin.us | perl - --sudo App::cpanminus
sudo cpanm -n -v Markdown::Render
```

[Back to Table of Contents](#table-of-contents)

# Building Components

To build test images for use with `App::FargateStack`, this directory
provides a `Makefile`.

To build each image, you need an AWS profile with permissions to
create, describe and push to ECR repositories.

```sh
AWS_PROFILE=my-profile make helloworld    # Build HelloWorld Docker image and its ECR repo
AWS_PROFILE=my-profile make http-test     # Build HTTP test service and its ECR repo

```
You can also run `make` with no arguments to build only the README:

```sh
AWS_PROFILE=my-profile make
```

[Back to Table of Contents](#table-of-contents)

# Deploying the Test Images

To deploy the images to your ECR repositories:

```sh
AWS_PROFILE=my-profile make install
```

@TOC_BACK@

# Cleaning Up and Forcing Rebuilds

The `Makefile` targets `clean` and `realclean` will remove
intermediate dependencies and force rebuild of certain
resources. As expected updates to the image dependencies like their
Dockerfiles or other assets they rely on will trigger rebuilds. If you
want to ensure a clean build run `make realclean` which will remove all
intermedidate depdencies and images.

If you really want to start from scratch remove the images if they
exist and run `make realclean`.

```
make realclean
make install
```

@TOC_BACK@
