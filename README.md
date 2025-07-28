# NAME

App::FargateStack

# SYNOPSIS

    app-FargateStack Options Command

## Commands

    help {subject}                 displays general help or help on a particular subject (see Note 2)
    apply                          reads config and creates resources
    create-service task-name       create a new service (see Note 4)
    delete-service task-name       delete an existing service
    list-zones domain              list the hosted zones for a domain
    plan                           reads config and reports on resource creation
    register task-name        
    run-task task-name
    update-target task-name
    version                        show version number

## Options

    -h, --help                 help
    -c, --config               path to the .yml configuration
    -C, --create-alb           forces creation of a new ALB instead of using an existing ALB
    -d, --dryrun               just report actions, do not apply
    --color, --no-color        default: color
    --log-level                'trace', 'debug', 'info', 'warn', 'error', default: info
    -p, --profile              AWS profile (see Note 1)
    -u, --update, --no-update  update config
    -w, --wait, --no-wait      wait for tasks to complete and dump log
    -v, --version              script version

## Notes

- 1. Use the --profile option to override the profile defined in
the configuration file.

    The Route 53 service uses the same profile unless you specify a profile
    name in the `route53` section of the configuraiton file.

- 2. You can get help using the `--help` option or use the help
command with a subject.

        app-FargateStack help overview

    If you do not provide a subject then you will get the same information
    as `--help`. Use `help list` to get a list of available subjects.

- 3. You must log at least at the 'info' level to report progress.
- 4. By default an ECS service is NOT created for you by default for daemon
and http tasks.

# OVERVIEW

_NOTE: This is a brief overview of `App::FargateStack`. To see a 
list of topics providing more detail use the `help list` command._

The `App::Fargate` framework, as its name implies provide developers
with a tool to create Fargate tasks and services. It has been designed
to make creating and launching Fargate based services as simple as
possible. Accordingly, it provides logical and pragmatic defaults
based on the common uses for Fargate based applications. You can
however customize many of the resources being built by the
script.

Using a YAML based configuration file, you specify the your required
resources and their attributes, run the `app-FargateStack` script and
launch your application.

Using this framework you can:

- ...build internal or external facing HTTP services that:
    - ...automatically provision certificates for external facing web applications
    - ...use an existing or create a new internal or external facing application load balancer (ALB).
    - ...automatically create an alias record in Route 53 for your domain
    - ...create a redirect listener rule to redirect port 80 requests to 443 
- ...create queues and buckets to support your application
- ...use a dryrun mode to report the resources that will built
before building them
- ...run `app-FargateStack` multiple times (idempotency)
- ...create daemon services
- ...create scheduled jobs
- ...execute adhoc jobs

## Additional Features

- - inject secrets into the container's environment using a simple syntax (See ["SECRETS MANAGEMENT"](#secrets-management))
- - detection and re-use of existing resources like EFS files systems, load balancers, buckets and queues
- - automatic IAM role and policy generation based on configured resources
- - define an launch multiple independent Fargate tasks and services under a single stack
- - automatic creation of log groups with customizable retention period
- - discovery of existing environment to intelligently populate configuration defaults

    back

## Minimal Configuration

Getting a Fargate task up and running requires that you provision and
configure multiple AWS resources. Stitching it together using
**Terraform** or **CloudFormation** can be tedious and time consuming,
even if you know what resources to provision AND how to stitch it
together.

The motivation behind writing this framework was to take the drudgery
of writing declarative resource generators for all of the resources required
to run a simple task, create basic web applications or RESTful
APIs. Instead, we wanted a framework that covered 90% of our use cases
while allowing our development workflow to go something like:

- 1. Create a Docker image that implements our worker, web app or API
- 2. Create a minimal configuration file that describes our application
- 3. Execute the framework's script and create the necessary AWS infrastructure
- 4. Launch the http server, daemon, scheduled job, or adhoc worker

Of course, this is only a "good idea" if #2 is truly minimal,
otherwise it becomes an exercise similar to using Terraform or
CloudFormation. So what is the minimum amount of configuration to
inform our framework for creating our Fargate worker? How 'bout this:

    ---
    app:
      name: my-stack
    tasks:
      my-worker:
        type: task
        image: my-worker:latest
        schedule: cron(50 12 * * * *)

Using this minimal configuration and running `app-FargateStack`t like this:

    app-FargateStack -c --profile prod minimal.yml plan

...would create the following resources in your default VPC:

- a cluster name `my-stack-cluster`
- a security group for the cluster
- an IAM role for the the cluster
- an IAM  policy that has permissions enabling your worker
- an ECS task definition for your work with defaults
- a CloudWatch log group
- an EventBridge target event
- an IAM role for EventBridge
- an IAM policy for EventBridge
- an EventBridge rule that schedules the worker

...so as you can see this can be a daunting task which becomes even
more annoying when you want your worker to be able to access other AWS
resources like buckets, queues or EFS directories.

## Web Applications

Creating a web application using a minimal configuration works too. To
build a web application you can start with this minimal configuration:

    ---
    app:
      name: my-web-app
    domain: my-web-app.example.com
    route53:
      zone_id: Z3YYX2RBQJTYM
    tasks:
      apache:
        type: https
        image: my-web-app:latest

This will create an externally facing web application for you with
these resources:

- A certificate for your domain
- A Fargate cluster
- IAM roles and policies
- A listener and listener rules
- A CloudWatch log group
- Security groups
- A target group
- A task definition
- An ALB if one is not detected

Once again, launching a Fargate service requires a
lot of fiddling with AWS resources! Getting all of the plumbing
installed and working requires a lot of what and how knowledge.

## Adding or Changing Resources

Adding or updating resources for an existing application should also be
easy. Updating the infrastrucutre should just be a matter of updating
the configuration and re-running the framework's script. When you
update the configuration the script will detect changes and update the
necessary resources.

Currently the framework supports adding a single SQS queue, a single
S3 bucket, volumes using EFS mount points and, environment variables
that can be injected from AWS SecretsManager.

    my-worker:
      image: my-worker:latest
      command: /usr/local/bin/my-worker.pl
      type: task
      schedule: cron(00 15 * * * *)   
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
when new resources are added (even secrets) and takes care of that for
you.

See `app-Fargate help configuration` for more information about
resources and options.

## Configuration as State

The framework attempts to be as transparent as possible regarding what
it is doing, how long it takes, what the result was and most
importantly _what defaults were used during resource
provisioning_. Every time the framework is run, the configuration file
is updated based on any new resources provisioned or configured.

This gives you a single view into your Fargate application.

# CLOUDWATCH LOG GROUPS

A CloudWatch log group is automatically provisioned for each
application stack. By default, the log group name is
/ecs/&lt;application-name>, and log streams are created per task.

For example, given the following configuration:

    app:
      name: my-stack
    ...
    tasks:
      apache:
        type: https

The framework will:

- Create a log group named /ecs/my-stack
- Configure the apache task to write log streams with a prefix
like my-stack/apache/\*

By default, the log group is set to retain logs for 14 days. You can
override this by specifying a custom retention period using the
`retention_days` key in the task's log\_group section:

    log_group:
      retention_days: 30

## Notes

- The log group is reused if it already exists.
- Only numeric values accepted by CloudWatch are valid for
retention\_days (e.g., 1, 3, 5, 7, 14, 30, 60, 90, etc.).
- You can customize the log group name by setting the name in the `log_group:` section.

        log_group:
          retention_days: 14
          name: /ecs/my-stack

# IAM PERMISSIONS

This framework uses a single IAM role for all tasks defined within an
application stack.  The assumption is that services within the stack
share a trust boundary and operate on shared infrastructure.  This
simplifies IAM management while maintaining strict isolation between
stacks.

IAM roles and policies are automatically created based on your
configuration.  Only the minimum required permissions are granted.
For example, if your configuration defines an S3 bucket, the ECS task
role will be permitted to access only that specific bucket—not all
buckets in your account.

# SECURITY GROUPS

A security group is automatically provisioned for your Fargate
cluster.  If you define a task of type `http` or `https`, the
security group attached to your Application Load Balancer (ALB) is
automatically authorized for ingress to your Fargate task.

# FILESYSTEM SUPPORT

EFS volumes are defined per task and mounted according to the task
definition. This design provides fine-grained control over EFS usage,
rather than treating it as a global, stack-level resource.

Each task that requires EFS support must include both a volume and
mountPoint configuration. The ECS task role is automatically updated
to allow EFS access based on your specification.

To specify EFS support in a task:

    efs:
      id: fs-1234567b
      mount_point: /mnt/my-stack
      path: /
      readonly:

## Field Descriptions

- id:

    The ID of an existing EFS filesystem. The framework does not provision
    the EFS, but will validate its existence in the current AWS account
    and region.

- mount\_point:

    The container path to which the EFS volume will be mounted.

- path:

    The path on the EFS filesystem to map to your container's mount point.

- readonly:

    Optional. Set to `true` to mount the EFS as read-only. Defaults to
    `false`.

## Additional Notes

- The ECS role's policy for your task is automatically modified
to allow read/write EFS access. Set `readonly:` in your task's
`efs:` section to false if only want read support.
- Your EFS security group must allow access from private subnets
where the Fargate tasks are placed.
- No changes are made to the EFS security group; the framework
assumes access is already configured
- Only one EFS volume is currently supported per task configuration.
- EFS volumes are task-scoped and reused only where explicitly configured.
- The framework does not automatically provision an EFS
filesystem for you. The framework does however validate that the
filesystem exists in the current account and region.

# CONFIGURATION

The `App::Fargate` framework maintains your application stack's state
using a YAML configuration file. Start the process of building your
stack by creating a YAML file with the minimum required elements.

    app:
      name: my-stack
    tasks:
      my-stack-daemon-1:
        image: my-stack-daemon:latest
        type: daemon

Each service corresponds to a containerized task you wish to
deploy. In this minimal configuration we are provisioning:

- ...a Fargate cluster in the us-east-1 region 
- ...one service that will run a daemon
- ...a service that runs in the default VPC in a private
subnet
- ...any required resources using the default AWS profile (or the
one specified by the environment variable AWS\_PROFILE)

Running `appFargateStack -c my-stack.yml plan` will analyze your
configuration file and report on the resources about to be created. It
will also update the configuration file with the defaults it used when
discovering the resources that need to be provisioned. You run
`app-FargateStack -c my-stack.yml apply` to actually build the stack.

## Environment Discovery

If you do not provide some configurtion values `app-FargateStack`
will inspect your AWS account to automatically set certain
configuration values. For example, if you do not set the `vpc_id:`
key, the script will look for a default VPC. Your VPC must contain at
least 1 private subnet which will be used to place your Fargate task.

## Configuration Details

The configuration is a YAML formatted file with various elements that
describe your application, its resources and their attributes.  Many
of these elements are optional when you first run the
`app-FargateStack` script. You must provide at least these sections:

    app:
      name: app-name
    tasks
      image: image-name
      type: daemon|task|http|https

For task type `http` or `https` you must also provide a domain name
for your HTTP service.

    domain: domain-name

Configuration schema is show below. All element are optional except
those noted above.

\---
account:
alb:
  arn:
  name:
  port:
  type:
app:
  name:
  version:
certificate\_arn:
cluster:
  arn:
  name:
default\_log\_group:
domain:
id:
last\_updated:
region:
role:
  arn:
  name:
  policy\_name:
route53:
  profile:
  zone\_id:
security\_groups:
  alb:
    group\_id:
    group\_name:
  fargate:
    group\_id:
    group\_name:
subnets:
  private:
  public:
tasks:
  apache:
    arn:
    cpu:
    family:
    image:
    log\_group:
      arn:
      name:
      retention\_days:
    memory:
    name:
    target\_group\_arn:
    target\_group\_name:
    task\_definition\_arn:
    type:
vpc\_id:

### 

# ENVIRONMENT VARIABLES

You specify environment variable and their values in the
`environment:` section of your task's configuration.

Example:

    task:
      apache:
        environment:
          ENVIRONMENT: prod

## Inject Secrets from SecretsManager Into the Environment

To inject secrets from SecretsManager into your environment add a
section name "secrets" to you task's configuration. Specify the path
and environment variable name as `path:enviroment-variable-name`.

Example:

    secrets:
      /my-stack/mysql-password:DB_PASSWORD

This would inject the secret value for `/my-stack/mysql-password`
into the environment variable "DB\_PASSWORD".

# SQS QUEUES

## Customizing Queue Attributes

# S3 BUCKETS

## Adding a Bucket Policy

# SCHEDULED JOBS

## Scheduling A Job

## Running an Adhoc Job

# HTTP SERVICES

## Overview

To create a Fargate HTTP service set the `type:` key in your task's
configuration section to "http" or "https".

The task type ("http" or "https") determines:

- the **type of load balancer** that will be used or created
- whether a **certificate will be used or created**
- what **default port** will be configured in your ALB's listener
rule

## Key Assumptions When Creating HTTP Services

- Your domain is managed in Route 53 and your profile can create
Route 53 record sets.

    _Note: If your domain is managed in a different AWS account, set a
    separate \`profile\` in the \`route53:\` section with sufficient
    permissions to update the relevant hosted zone._

- Your Fargate task will be deployed in a private subnet and
will listen on port 80.
- No certificate will be provisioned for internal facing
applications. Traffic by default to internal facing applications
(those that use an internal ALB) will be insecure.

## Architecture

When you set your task type to `http` or `https` a default
architecture depicted below will be provisioned.

                            (optional)
                        +------------------+
                        |  Internet Client |
                        +--------+---------+
                                 |
                      [only if ALB is external]
                                 |
                    +------------v--------------+
                    |  Route 53 Hosted Zone     |
                    |  Alias: myapp.example.com |
                    |     --> ALB DNS Name      |
                    +----------+----------------+
                                 |
                      +----------v----------+
                      | Application Load    |
                      | Balancer (ALB)      |
                      | [internal or        |
                      |  internet-facing]   |
                      |                     |
                      | Listeners:          |
                      |   - Port 80         |
                      |   - Port 443 w/ TLS |
                      |     + ACM Cert      |
                      |       (TLS/SSL)     |
                      |     [if external]   |
                      +----------+----------+
                                 |
                          +------v-------+
                          | Target Group |
                          +------+-------+
                                 |
                         +-------v---------+
                         | ECS Service     |
                         | (Fargate Task)  |
                         +-------+---------+
                                 |
                       +---------v----------+
                       | VPC Private Subnet |
                       +--------------------+

This default architecture provides a repeatable, production-ready
deployment pattern for HTTP services with minimal configuration and
robust discovery.

## Behavior by Task Type

For HTTP services, you set the task type to either "http" or "https"
(these are the only options that will trigger a task to be configured
for HTTP services). The table below summarizes the configurations by
task type.

    +-------+----------+-------------+-----------+---------------+
    | Type  | ALB type | Certificate |    Port   |  Hosted Zone  |
    +-------+----------+-------------+-----------+---------------+
    | http  | internal |    No       |    80     |   private     |
    | https | external |   Yes       |   443     |   public      |
    |       |          |             | 80 => 443 |               |
    +-------+----------+-------------+-----------+---------------+

_NOTE: You must provide a domain name for both an internal and
external facing HTTP service. This also implies you must have a
private hosted zone for internal services and a public hosted zone for
you domain for external services._

Your task type will also determine where the script looks for an
existing ALB to use (private vs public subnet). If you want to force
the creation of a new ALB use the `--create-alb` option.

If you do not provide a hosted zone id in your initial configuration,
the framework the framework searches for a hosted zone in Route 53
corresponding to your domain. If the task type is `https`, the script
looks for a public zone, otherwise it looks for a private zone.

## ACM Certificate Management

If the task type is "https" and no ACM certificate currently exists
for your domain, the framework will automatically provision one. The
certificate will be created in the same region as the ALB and issued
via AWS Certificate Manager. 

If the ALB is internet-facing, the certificate is issued via DNS
validation and automatically attached to the listener on port 443.

## Port and Listener Rules

For external-facing apps, a separate listener on port 80 is
created. It forwards traffic to port 443 using a default redirect rule
(301).

If you want your internal application to listen on a port other than
80, set `port` to your custom port value in the task's configuration
section. This only changes the container port exposed to the target
group; the listener on the ALB will still forward based on its own
rule.

## Example Minimal Configuration

    app:
      name: http-test
    domain: http-test.example.com
    task:
      apache:
        type: http
        image: http-test:latest

Based on this minimal configuration `app-FargateStack` will enrich
the configuration with appropriate defaults and proceed to provision
your HTTP service. In order to do that, the framework attempts to
discover some of the resources required for your service. If your
environment is not compatible with creating the service, the framework
will provide helpful error messages and abort the process.

Given this minimal configuration for an internal ("type: http") or
external ("type: https") HTTP service, discovery entails:

- 1. ...determining your VPC ID
- 2. ...finding the private subnet IDs
- 3. ...looking for an existing load balancer
- 4. ...finding your load balancer's security group (if an ALB exists)
- 5. ...looking for a listener rule on port 80 (and 443 if "type:
https"), including a default forwarding redirect rule
- 6. ...looking for a hosted zone in Route 53 that supports your domain
- 7. ...setting other defaults for other resources to be built (log
groups, cluster, target group, etc)
- 8. ...determining if an ACM certificate exists for your domain
(type "https" only)

_Note: Discovery of these resources is only done when they are
missing from your configuration. If you have multiple VPCs for example
you can set `vpc_id:` in the configuration to identify the target
VPC.  Likewise with other resources like subnets, ALBs, Route 53,
etc. As `app-FargateStack` finds your resources it fills out the
sections in the configuration giving you complete insight into how it
will provision resources. See [CONFIGURATION](https://metacpan.org/pod/CONFIGURATION) for complete details on
resource configurations._

Your environment will be considered valid only if:

- You have at least 1 private subnet available for deployment
- You have a hosted zone for your domain of the appropriate type
(private for type "http", public for type "https")

As discovery progresses, existing and required resources are logged
and updated in the configuration file. If you are NOT running in
dryrun mode, resources will be created immediately as they are
discovered to be missing from your environment.

## Application Load Balancer

When you provision an http service whether or not it is secure we will
place the service behind an application load balancer. Your Fargate
service is created in private subnets, so your VPC must contain at
least one private subnet.  Your load balancer can either be internally
or externally facing. 

By default, the framework looks for a load balancer with the correct
scheme (internal or internet-facing), in a subnet aligned with your
task type, and reuses it if found. Otherwise, a new ALB is
provisioned. When creating a new ALB, `app-FargateStack` will also
create the necessary listeners for the ports you have configured.

While it is possible to avoid the use or creation of a load balancer
for your service, the framework forces one to be created for two
reasons. Firstly, the IP address of your service may not be stable and
is not friendly for development or production purposes. The framework
is, after all trying its best to grease the wheels and prevent you
from having to think too hard.

Secondly, it is almost guaranteed that you will eventually want to use
a domain name for your production service - whether it is an
internally facing microservice or an externally facing web
application.

Creating an alias in Route 53 for your domain to the ALB ensures you
don't need to update configurations with the service's dynamic IP
address. Additionally, using a load balancer might be useful for
creating custom routing rules to your service and of course for
support traffic management  as you scale your containers.

Therefore the framework's decision was to force the use of ALB and
create an alias record (A) for your domain in AWS for both internal
and external facing services.

## Roadmap for HTTP Services

- path based routing on ALB listeners
- ECS service health check configuration
- Auto-scaling policies

# LIMITATIONS

- Support for only 1 http services
- Limited configuration options for some resources
- Some out of band infrastructure changes may break the ability
to re-run `app-FargateStack` without manually updating the
configuration
- Support for only 1 EFS filesystem per task

# ROADMAP

- destroy {task-name}

    Destroy all resources for all tasks or for one task. Buckets and queues will not be deleted.

- stop, start services
- enable/disable task
- health check configuration
- scaling configuration

# SEE ALSO

[IPC::Run](https://metacpan.org/pod/IPC%3A%3ARun), [App::Command](https://metacpan.org/pod/App%3A%3ACommand), [App::AWS](https://metacpan.org/pod/App%3A%3AAWS), [CLI::Simple](https://metacpan.org/pod/CLI%3A%3ASimple)

# AUTHOR

Rob Lauer - rclauer@gmail.com

# LICENSE

This script is released under the same terms as Perl itself.

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 1047:

    You forgot a '=back' before '=head2'

- Around line 1236:

    Expected '=item \*'

- Around line 1276:

    Non-ASCII character seen before =encoding in 'bucket—not'. Assuming UTF-8

- Around line 1534:

    You forgot a '=back' before '=head2'

- Around line 1552:

    You forgot a '=back' before '=head2'

- Around line 1631:

    &#x3d;back without =over

- Around line 1655:

    &#x3d;back without =over
