# README-HACKING

This README will explain what you need to build `App::FargateStack'
from source and possible contribute to the project.

# Prerequisites

`App::FargateStack` is a Perl based application and as such you should
have a complete Perl installation. `perl` version 5.16.3 is sufficient
although older versions _may_ work...ymmv.

## Utilities

* `curl`
* `unzip`
* `git`

## Perl Module Dependencies

The modules required by `App::FargateStack` are listed in the
`requires` file. You can install all of the required modules by using
`cpanm`. Some modules require additioanl libraries,  `make` and `gcc`
so make sure these dependencies are installed before you proceed (this
list may be incomplete):

* `gcc`
* `make`
* `automake`
* `libexpat-dev`
* `libssl-dev`
* `libzip-dev`

>> Library names may differ on different distributions. The libraries named above can be installed in Debian based distributions.

Typically, I install Perl dependencies in my home directory
to avoid overwriting system `perl` artifacts:

```
eval $(perl -I$HOME/lib/perl5 -Mlocal::lib=$HOME)
curl -L https://cpanmin.us | perl - App::cpanminus
```

...then

for a in $(cat requires); do \
  cpanm -n -v -l $HOME $a; \
done
```

## AWS CLI

`App::FargateStack` uses the `aws` CLI script to invoke AWS APIs when
creating and describing resources. Visit the [AWS
page](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
describing the latest installation process, however this recipe below
may still work:

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
./aws/install
```

Make sure you configure the CLI with your AWS profile for the account
you will be using for building and testing `App::FargateStack`.

## Additional Dependencies for Building the Project

* [`Markdown::Render`](https://metacpan.org/pod/Markdown::Render) - provides `md-utils.pl`
* [`CPAN::Maker`](https://metacpan.org/pod/CPAN::Maker) - provide `make-cpan-dist.pl`

