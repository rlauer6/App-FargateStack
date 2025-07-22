# NAME

app-fargateStack

# SYNOPSIS

    app-fargateStack Options Command

## Commands

    apply                          determines resource gaps and applie changes
    create{-service} service-name  create a new service
    delete{-service} service-name  delete an existing service
    help {subject}                 displays general help or help on a particular subject (see Note 2)
    plan
    start{-service} service-ame    start a service
    stop{-service} service-name    stop a service
    version                        show version number

## Options

    -h, --help                 help
    -c, --config               path to the .yml config file
    -C, --create-alb           forces creation of a new ALB instead of using an existing ALB
    -p, --profile              AWS profile (see Note 1)
    -u, --update, --no-update  update config
    -v, --version              script version

## Notes

- 1. Use the --profile option ot override the profile defined in
the configuration file.

    The Route53 service uses the same profile unless you specify a profile
    name in the `route53` section of the configuraiton file.

- 2. You can get help program options using --help or use the help
command with a subject.

    If you do not provide a subject then you will get the same information
    as `--help`. Use help ? to get a list of subjects you can get help on.

# DESCRIPTION

# OVERVIEW

The `App::Fargate` framework is designed to make creating and
launching Fargate based services as simple as possible. Using a YAML
based configuration file you specify the services and resources
required to create your services.

Features of the stack that can be built with this tool include:

- Creation of either an internal or external facing HTTP service.
- Automatic creation of a certificate for external facing HTTP services.
- Creation of an internal or external facing application load balancer.
    - Discovery of existing ALBs or ability to force creation of a new ALB
    - Redirect listener rule that redirects port 80 requests to 443 
- Creation of queues and buckets to support your application
- Dryrun mode to examine what will created before resources are built
- Idempotent behavior allows you to run script multiple times

# IAM PERMISSIONS

This framework uses a single IAM role for all defined tasks in a
given application stack. The assumption is that all services defined
in a stack operate on shared infrastructure and can be trusted
equally. This simplifies IAM management while maintaining a secure
boundary around the stack as a whole.

# CONFIGURATION

The `App::Fargate` framework maintains your application stack's state
using a YAML configuration file. Start the process of building your
stack by creating a `.yml` file with the minimum required elements.

    app:
      name: my-stack
    services:
      my-stack-daemon-1:
        command: /usr/local/bin/start-daemon
        image: my-stack-daemon:latest
        type: daemon

Each service corresponds to a containerized task you wish to
deploy. In this minimal configuration we are provisioning:

- ...a Fargate cluster in the us-east-1 region 
- ...one service that will run a daemon
- ...a service that run in the default VPC in a private
subnet (or public subnet if that is the only subnet available)
- ...resources using the default AWS profile (or the one specified
by the environment variable AWS\_PROFILE)

Running `app-Fargate -c my-stack.yml plan` will analyze you
configuration file and report on the resources about to be created. It
will also update the configuration file with the defaults it used when
deciding what to do. Run `app-Fargate -c my-stack.yml apply` to build
the stack.

# LOAD BALANCERS

When you provision an http service whether it is secure or not we will
place the service behind a load balancer. The framework will provision
an ALB for you or you can use an ALB currently in your VPC.

- 1. An ALB will be created if no usable ALB exists when the service
type is http or https.

    If no ALB is defined in the configuration and the service type is
    `http` or `https` then the script will look for an internal or
    inter-facing ALB depending on the service type. If no ALB is found,
    one will be provisioned.

    If multiple ALBs exist, the script will terminate and display a list
    of ALBs. The user should then pick one and set `alb_arn` in the
    configuration file.

- 2. `domain` is required if service type is `` http" or `https` ``
- 3. A certificate will be created for the domain if the service
type is `https` and no certificate for that domain currently exists.
- 4. If an ALB is required and no `type` is defined in the
configuration it assumed to be an internal ALB for service type
`http` and internet-facing for service type `https`
- 5. If no port is defined for the ALB port 443 will be used for
service type `https` and 80 for service type `http`.
- 6. If `redirect_80` is not explicitly set and the ALB port is
443, a listener rule to redirect 80 to 443 will automatically be
provisioned.
- 7. You can set the port for the ALB to any valid custom value.

        ERROR: Multiple ALBs found in region us-east-1 for this VPC.
        Please specify the ALB ARN in your configuration to continue.
        
        Candidate ALBs:
          - my-alb-1 [arn:aws:elasticloadbalancing:...]
          - my-alb-2 [arn:aws:elasticloadbalancing:...]
          - internal-service-alb [arn:aws:elasticloadbalancing:...]
        
        Hint: Add "alb_arn" to your config to reuse an existing ALB.

# SEE ALSO

[IPC::Run](https://metacpan.org/pod/IPC%3A%3ARun)

# AUTHOR

Rob Lauer - rclauer@gmail.com

# LICENSE

This script is released under the same terms as Perl itself.

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 637:

    Unterminated C<...> sequence

- Around line 669:

    &#x3d;back without =over
