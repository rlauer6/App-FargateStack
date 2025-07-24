# NAME

App::FargateStack

# SYNOPSIS

    app-FargateStack Options Command

## Commands

    help {subject}                 displays general help or help on a particular subject (see Note 2)
    apply                          determines resources required and applies changes
    create{-service} task-name     create a new service
    delete{-service} task-name     delete an existing service
    plan
    register task-name
    run-task task-name
    update-target task-name
    version                        show version number

## Options

    -h, --help                 help
    -c, --config               path to the .yml config file
    -C, --create-alb           forces creation of a new ALB instead of using an existing ALB
    -d, --dryrun               just report actions, do not apply
    --color, --no-color        default: color
    -p, --profile              AWS profile (see Note 1)
    -u, --update, --no-update  update config
    -v, --version              script version

## Notes

- 1. Use the --profile option to override the profile defined in
the configuration file.

    The Route53 service uses the same profile unless you specify a profile
    name in the `route53` section of the configuraiton file.

- 2. You can get help using the `--help` option or use the help
command with a subject.

        app-FargateStack help overview

    If you do not provide a subject then you will get the same information
    as `--help`. Use `help ?"` or `help list` to get a list of available subjects.

# OVERVIEW

The `App::Fargate` framework, as its name implies provide developers
with a way to create Fargate tasks and services. It has been designed
to make creating and launching Fargate based services as simple as
possible. Accordingly, it is opinionated and provides logical and
pragmattic defaults. Using a YAML based configuration file, you specify
the resources required to create your services.

Using this framework you can:

- ...specify internal or external facing HTTP services that will:
    - ...automatically provision certificates for external facing web applications
    - ...use existing or create new internal or external facing application load balancers (ALB).
    - ...automatically create an alias record in Route 53 for your domain
    - ...create redirect listener rule to redirect port 80 requests to 443 
- ...create queues and buckets to support your application
- ...use the dryrun mode to examine what will be created before resources are built
- ...run the script multiple times (idempotency)
- ...create daemon services
- ...create scheduled jobs
- ...execute adhoc jobs

## Minimal Configuration

Getting a Fargate task up and running requires that you provision and
configure multiple AWS resources. Stitching it together using
Terraform or CloudFormation can be tedious and time consuming, even if
you know what resources to provision and how to stitch it together.

The motivation behind writing this framework was to take the drudgery
of writing declarative resource generators for every resource
required. Instead, we want a framework that covers 90% of our use
cases and allows our development workflow to go something like:

- 1. Create a Docker image that implements our worker
- 2. Create a minimal configuration file that describes our worker
- 3. Execute the framework's script and create the necessary AWS infrastructure
- 4. Run the task, service or the scheduled job

This is only a "good idea" if #2 is truly minimal, otherwise it becomes
an exercise similar to using Terraform or CloudFormation. So what is
the minimum amount of configuration to inform our framework for
creating our Fargate worker? How 'bout this:

    ---
    app:
      name: my-stack
    tasks:
      my-worker:
        type: task
        image: my-worker:latest
        schedule: cron(50 12 * * * *)

Using this minimal configuration and running the script like this:

    app-Fargate -c --profile prod minimal.yml plan

...would create the following resources in your default VPC:

- a cluster name `my-stack-cluster`
- a security group for the cluster
- an IAM role for the the cluster
- an IAM  policy that has permissions enabling your worker
- an ECS task definition for your work with defaults
- a CloudWatch log group
- an EventBridge target event
- an IAM role for EventBridge
- an IAM policy for EventBridget
- an EventBridge rule that schedules the worker

...so as you can see this can be a daunting task which becomes even
more annoying when you want your worker to be able to access other AWS
resources like buckets, queues or EFS directories.

## Adding More Resources

Adding more resources for my worker should also be easy. Updating the
infrastrucutre should just be a matter of updating the configuration
and re-running the framework's script.

Currently the framework supports adding a single SQS queue, a single
S3 bucket, volumes using EFS mount points and, environment variables
that can be injected from AWS SecretsManager.

    my-worker:
      image: my-worker:latest
      command: /usr/local/bin/my-worker.pl
      type: task
      schedule: cron(00 15 * * * * )   
      bucket:
        name: my-worker-bucket
      queue:
        name: my-worker-queue
      environment:
        ENVIRONMENT=prod
      secrets:
        db_passord:DB_PASSWORD
      efs:
        id: fs-abcde12355
        path: /
        mount_point: /mnt/my-worker

Adding new resources would normally require you to update your
policies to allow your worker to access these resource. However, the
framework automatically detects that the policy needs to be updated
when new resoures are added (even secrets) and takes care of that for
you.

See `app-Fargate help configuration` for more information about
resources and options.

## Configuration as State

The framework attempts to be as transparent as possible regarding what
it is doing, how long it takes, what the result was and most
importantly _what defaults it has used to configure the resources it
has provisioned_. Every time the framework is run, the configuration
file is updated based on any new resources provisioned or configured.

This gives you a single view into your Fargate application.

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
    tasks:
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

- 2. `domain` is required if service type is `http` or `https`
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

# TO DO

- destroy {task-name}

    Destroy all resources for all tasks or for one task. Buckets and queues will not be deleted.

- test example http, daemon services
- update and organize documentation
- stop, start services
- enable/disable task
- list-tasks
- check for config changes

# SEE ALSO

[IPC::Run](https://metacpan.org/pod/IPC%3A%3ARun)

# AUTHOR

Rob Lauer - rclauer@gmail.com

# LICENSE

This script is released under the same terms as Perl itself.
