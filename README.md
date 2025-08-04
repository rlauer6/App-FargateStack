# Table of Contents

* [NAME](#name)
* [SYNOPSIS](#synopsis)
* [DESCRIPTION](#description)
  * [Features](#features)
* [USAGE](#usage)
  * [Commands](#commands)
  * [Options](#options)
  * [Notes](#notes)
* [OVERVIEW](#overview)
  * [Additional Features](#additional-features)
  * [Minimal Configuration](#minimal-configuration)
  * [Web Applications](#web-applications)
  * [Adding or Changing Resources](#adding-or-changing-resources)
  * [Configuration as State](#configuration-as-state)
* [CLI OPTION DEFAULTS](#cli-option-defaults)
  * [Disabling and Resetting](#disabling-and-resetting)
  * [Notes](#notes)
* [COMMAND LIST](#command-list)
  * [Configuration File Naming](#configuration-file-naming)
  * [Command Logging](#command-logging)
  * [Command Descriptions](#command-descriptions)
    * [help](#help)
    * [apply](#apply)
    * [create-service](#create-service)
    * [delete-service](#delete-service)
    * [disable-scheduled-task](#disable-scheduled-task)
    * [enable-scheduled-task](#enable-scheduled-task)
    * [list-tasks](#list-tasks)
    * [list-zones](#list-zones)
    * [logs](#logs)
    * [plan              ](#plan-)
    * [redeploy](#redeploy)
    * [run-task](#run-task)
    * [status](#status)
    * [stop-task](#stop-task)
    * [stop-service](#stop-service)
    * [start-service](#start-service)
    * [update-policy](#update-policy)
    * [update-target](#update-target)
    * [version              ](#version-)
* [CLOUDWATCH LOG GROUPS](#cloudwatch-log-groups)
  * [Notes](#notes)
* [IAM PERMISSIONS](#iam-permissions)
* [SECURITY GROUPS](#security-groups)
* [FILESYSTEM SUPPORT](#filesystem-support)
  * [Field Descriptions](#field-descriptions)
  * [Additional Notes](#additional-notes)
* [CONFIGURATION](#configuration)
  * [GETTING STARTED](#getting-started)
  * [VPC AND SUBNET DISCOVERY](#vpc-and-subnet-discovery)
  * [SUBNET SELECTION](#subnet-selection)
  * [REQUIRED SECTIONS](#required-sections)
  * [FULL SCHEMA OVERVIEW](#full-schema-overview)
* [ENVIRONMENT VARIABLES](#environment-variables)
  * [BASIC USAGE](#basic-usage)
  * [SECURITY NOTE](#security-note)
  * [INJECTING SECRETS FROM SECRETS MANAGER](#injecting-secrets-from-secrets-manager)
  * [BEST PRACTICES](#best-practices)
* [SQS QUEUES](#sqs-queues)
  * [BASIC CONFIGURATION](#basic-configuration)
  * [DEFAULT QUEUE ATTRIBUTES](#default-queue-attributes)
  * [DLQ DESIGN NOTE](#dlq-design-note)
  * [IAM POLICY UPDATES](#iam-policy-updates)
* [SCHEDULED JOBS](#scheduled-jobs)
  * [SCHEDULING A JOB](#scheduling-a-job)
  * [RUNNING AN ADHOC JOB](#running-an-adhoc-job)
  * [SERVICES VS TASKS](#services-vs-tasks)
* [S3 BUCKETS](#s3-buckets)
  * [BASIC CONFIGURATION](#basic-configuration)
  * [RESTRICTED ACCESS](#restricted-access)
  * [IAM-BASED ENFORCEMENT](#iam-based-enforcement)
  * [USING EXISTING BUCKETS](#using-existing-buckets)
* [HTTP SERVICES](#http-services)
  * [Overview](#overview)
  * [Key Assumptions When Creating HTTP Services](#key-assumptions-when-creating-http-services)
  * [Architecture](#architecture)
  * [Behavior by Task Type](#behavior-by-task-type)
  * [ACM Certificate Management](#acm-certificate-management)
  * [Port and Listener Rules](#port-and-listener-rules)
  * [Example Minimal Configuration](#example-minimal-configuration)
  * [Application Load Balancer](#application-load-balancer)
    * [Why Does the Framework Force the Use of an Load Balancer?](#why-does-the-framework-force-the-use-of-an-load-balancer)
  * [Roadmap for HTTP Services](#roadmap-for-http-services)
* [CURRENT LIMITATIONS](#current-limitations)
* [TROUBLESHOOTING](#troubleshooting)
  * [Why is my task or service still using an old image?](#why-is-my-task-or-service-still-using-an-old-image)
    * [One-off tasks: `run-task` uses a fixed image digest](#one-off-tasks-run-task-uses-a-fixed-image-digest)
    * [Services: `create-service` and `update-service` use frozen images too](#services-create-service-and-update-service-use-frozen-images-too)
    * [`--force-new-deployment` re-pulls image tags (if not pinned by digest)](#--force-new-deployment-re-pulls-image-tags-if-not-pinned-by-digest)
    * [Confirm what your task definition is using](#confirm-what-your-task-definition-is-using)
    * [Best practices](#best-practices)
* [ROADMAP](#roadmap)
* [SEE ALSO](#see-also)
* [AUTHOR](#author)
* [LICENSE](#license)
* [POD ERRORS](#pod-errors)
---
[Back to Table of Contents](#table-of-contents)

# NAME

App::FargateStack

[Back to Table of Contents](#table-of-contents)

# SYNOPSIS

    # Dry-run and analyze the configuration
    app-FargateStack plan -c my-stack.yml

    # Provision the full stack
    app-FargateStack apply -c my-stack.yml

[Back to Table of Contents](#table-of-contents)

# DESCRIPTION

_NOTE: This is a work in progress. The documentation may be
incomplete. Expect some features to change and more features to be
added. See the ["ROADMAP"](#roadmap) section for upcoming features._

**App::FargateStack** is a lightweight deployment framework for Amazon
ECS on Fargate.  It enables you to define and launch containerized
services with minimal AWS-specific knowledge and virtually no
boilerplate. Designed to simplify cloud infrastructure without
sacrificing flexibility, the framework lets you declaratively specify
tasks, IAM roles, log groups, secrets, and networking in a concise
YAML configuration.

By automating the orchestration of ALBs, security groups, EFS mounts,
CloudWatch logs, and scheduled or daemon tasks, **App::FargateStack**
reduces the friction of getting secure, production-grade workloads
running in AWS. You supply a config file, and the tool intelligently
discovers or provisions required resources.

It supports common service types such as HTTP, HTTPS, daemon, and cron
tasks, and handles resource scoping, role-based access, and health
checks behind the scenes.  It assumes a reasonable AWS account layout
and defaults, but gives you escape hatches where needed.

**App::FargateStack** is ideal for developers who want the power of ECS
and Fargate without diving into the deep end of Terraform,
CloudFormation, or the AWS Console.

## Features

- Minimal configuration: launch a Fargate service with just a task name
and container image
- Supports multiple task types: HTTP, HTTPS, daemon, cron (scheduled)
- Automatic resource provisioning: IAM roles, log groups, target groups,
listeners, etc.
- Discovers and reuses existing AWS resources when available (e.g.,
VPCs, subnets, ALBs)
- Secret injection from AWS Secrets Manager
- CloudWatch log integration with configurable retention
- Optional EFS volume support (per-task configuration)
- Public or private service deployment (via ALB in public subnet or
internal-only)
- Built-in service health check integration
- Automatic IAM role and policy generation based on task needs
- Optional HTTPS support with ACM certificate discovery and creation
- Lightweight dependency stack: Perl, AWS CLI, a few CPAN modules
- Convenient CLI: start, stop, update, and tail logs for any service

[Back to Table of Contents](#table-of-contents)

# USAGE

## Commands

    Command                Arguments            Description
    -------                ---------            -----------
    apply                                       reads config and creates resources
    create-service         task-name            create a new service (see Note 4)
    delete-service         task-name            delete an existing service
    disable-scheduled-task task-name            disable a scheduled task
    enable-scheduled-task task-name             enable a scheduled task
    help                   [subject]            displays general help or help on a particular subject (see Note 2)
    list-tasks                                  list running tasks
    list-zones             domain               list the hosted zones for a domain
    logs                   task-name start end  display CloudWatch logs (see Note 5)
    plan                                        reads config and reports on resource creation
    register               task-name            register a task name
    run-task               task-name            launches an adhoc task
    start-service          task-name [count]    starts a service
    status                 task-name            provides the current status for a task
    stop-service           task-name            stops a running service
    update-policy                               updates the ECS policy in the event of resource changes
    update-target          task-name            force update of target definition
    version                                     display the current version number

## Options

    -h, --help                 help
        --cache, --no-cache    use the configuration file as the source of truth (see Note 8)
    -c, --config               path to the .yml configuration
    -C, --create-alb           forces creation of a new ALB, prevents use of an existing ALB
    --color, --no-color        default: color
    -d, --dryrun               just report actions, do not apply
    -f, --force                force action (depends on context)
    --history, --no-history    save cli parameters to .fargatestack/defaults.json
    --log-level                'trace', 'debug', 'info', 'warn', 'error', default: info (See Note 6)
    --log-time, --no-log-time  for logs command, output CloudWatch timestamp (default: --no-log-time)
    --log-wait, --no-log-wait  for logs command, continue to monitor logs (default: --log-wait)
    --log-poll-time            amount of time in seconds to sleep between requesting new log events
    -p, --profile              AWS profile (see Note 1)
        --route53-profile      set this if your Route 53 zones are in a different account (See Note 10)
    -s, --skip-register        skips registering a new task definition when using update-target (See Note 7)
    -u, --update, --no-update  update config (See Note 9)
    -U, --unlink, --no-unlink  delete or keep temp files (default: --unlink)
    -w, --wait, --no-wait      wait for tasks to complete and then dump the log (applies to adhoc tasks)
    -v, --version              script version

## Notes

- (1) Use the --profile option to override the profile defined in
the configuration file.

    _Note: The Route 53 service uses the same profile unless you specify
    `--route53-profile` or set a profile name in the `route53` section
    of the configuration file._

- (2) You can get help using the `--help` option or use the help
command with a subject.

        app-FargateStack help overview

    If you do not provide a subject then you will get the same information
    as `--help`. Use `help help` to get a list of available subjects.

- (3) You must log at least at the 'info' level to report progress.
- (4) By default an ECS service is NOT created for you by default
for daemon and http tasks.
- (5) You can tail or display a set of log events from a task's
log stream:

        app-Fargate logs [--log-wait] [--log-time] start end

    - --log-wait --no-log-wait (optional)

        Continue to monitor stream and dump logs to STDOUT

        default: --log-wait

    - --log-time, --no-log-time (optional)

        Output the CloudWatch timestamp of the message.

        default: --log-time

    - task-name

        The name of the task whose logs you want to view.

    - start

        Starting date and optionally time of the log events to display. Format can be one
        of:

            Nd => N days ago
            Nm => N minutes ago
            Nh => N hours ago

            mm/dd/yyyy
            mm/dd/yyyy hh:mm::ss

    - end

        If provided both start and end must date-time strings.

- (6) The default log level is 'info' which will create an audit
trail of resource provisioning. Certain commands log at the 'error'
level to reduce console noise. Logging at lower levels will prevent
potential useful messages from being displayed. To see the AWS CLI
commands being executed, log at the 'debug' level. The 'trace' level
will output the result of the AWS CLI commands.
- (7) Use `--skip-register` if you want to update a tasks target
rule without registering a new task definition. This is typically done
if for some reason your target rule is out of sync with your task
definition version.
- (8) To speed up processing and avoid unnecessary API calls the
framework considers the configuration file the source of truth and a
reliable representation of the state of the stack. If you want to
re-sync the configuration file set `--no-cache` and run `plan`. In
most cases this should not be necessary as the framework will
invalidate the configuration if an error occurs forcing a re-sync on
the next run of `plan` or `apply`.
- (9) `--no-update` is not permitted with `apply`. If you need a
dry plan without applying or updating the config, use `--dryrun` (and
optionally `--no-update`) with `plan`.
- (10) Set `--route53-profile` to the profile that has
permissions to manage your hosted zones. By default the script will
use the default profile.

[Back to Table of Contents](#table-of-contents)

# OVERVIEW

_NOTE: This is a brief overview of `App::FargateStack`. To see a 
list of topics providing more detail use the `help help` command._

The `App::FargateStack` framework, as its name implies provide developers
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
    - ...create a listener rule to redirect port 80 requests to 443 
- ...create queues and buckets to support your application
- ...use a dryrun mode to report the resources that will be built
before building them
- ...run `app-FargateStack` multiple times (idempotency)
- ...create daemon services
- ...create scheduled jobs
- ...execute adhoc jobs

## Additional Features

- - inject secrets into the container's environment using a simple
syntax (See ["INJECTING SECRETS FROM SECRETS MANAGER"](#injecting-secrets-from-secrets-manager))
- - detection and re-use of existing resources like EFS files systems, load balancers, buckets and queues
- - automatic IAM role and policy generation based on configured resources
- - define and launch multiple independent Fargate tasks and services under a single stack
- - automatic creation of log groups with customizable retention period
- - discovery of existing environment to intelligently populate configuration defaults

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

- Create a Docker image that implements our worker, web app or API
- Create a minimal configuration file that describes our application
- Execute the framework's script and create the necessary AWS infrastructure
- Launch the http server, daemon, scheduled job, or adhoc worker

Of course, this is only a "good idea" if second point is truly
minimal, otherwise it becomes an exercise similar to using Terraform
or CloudFormation. So what is the minimum amount of configuration to
inform our framework so it can create our Fargate worker? How's this
for minimal?

    ---
    app:
      name: my-stack
    tasks:
      my-worker:
        type: task
        image: my-worker:latest
        schedule: cron(50 12 * * * *)

Using this minimal configuration and running `app-FargateStack` like this:

    app-FargateStack plan

...the framework would create the following resources in your VPC:

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
easy. Updating the infrastructure should just be a matter of updating
the configuration and re-running the framework's script. When you
update the configuration the script will detect changes and update the
necessary resources.

Currently the framework supports adding a single SQS queue, a single
S3 bucket, volumes using EFS mount points and, environment variables
that can be injected from AWS Secrets Manager.

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
        db_password:DB_PASSWORD
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
is updated based on any new resources provisioned or configured.  For
example, if you did not specify subnets, they are inferred by
inspecting your VPC and automatically added to the configuration file.

This gives you a single view into your Fargate application

[Back to Table of Contents](#table-of-contents)

# CLI OPTION DEFAULTS

When enabled, `App::FargateStack` automatically remembers the most recently
used values for several CLI options between runs. This feature helps streamline
repetitive workflows by eliminating the need to re-specify common arguments
such as the AWS profile, region, or config file.

The following options are tracked and persisted:

- `--profile`
- `--region`
- `--config`
- `--route53-profile`
- `--max-events`

These values are stored in `.fargatestack/defaults.json` within your current
project directory. If you omit any of these options on subsequent runs, the
most recently used value will be reused.

Typically, you would create a dedicated project directory for your stack and
place your configuration file there. Once you invoke a command that includes
any of the tracked CLI options, the `.fargatestack/defaults.json` file will be
created automatically. Future commands run from that directory can then omit
those options.

## Disabling and Resetting

Use the `--no-history` option to temporarily disable this feature for a single
run. This allows you to override stored values without modifying or deleting
them.

To clear all saved defaults entirely, use the `reset-history` command. This
removes all of the tracked values from the `.fargatestack/defaults.json` file,
but preserves the file itself.

## Notes

Only explicitly provided CLI options are tracked. Values derived from
environment variables or configuration files are not saved.

This feature is enabled by default.

[Back to Table of Contents](#table-of-contents)

# COMMAND LIST

The basic syntax of the framework's CLI is:

    app-FargateStack command --config fargate-stack.yml [options] command-args

You must provide at least a command.

## Configuration File Naming

Your configuration file can be named anything, but by convention your
configuration file should have a `.yml` extension. If you don't
provide a configuration filename the default configuration file
`fargate-stack.yml` will be used. You can also set the
`FARGATE_STACK_CONFIG` environment variable to the name of your
configuration file.

## Command Logging

- Commands will generally produce log output at the default level
(`info`). You can see what AWS commands are being executed using the
`debug` level. If you'd like see the results of the AWS CLI commands use the
`trace` level.
- Commands that are expected to produce informational output
(e.g. `status`, `logs`, `list-tasks`, `list-zone`, etc) will log
at the `error` level which will eliminate log noise on the console.
- Logs are written to STDERR.
- The default is to colorize log
messages. Use `--no-color` if you don't like color.

## Command Descriptions

### help

    help [subject]

Displays basic usage or help on a particular subject. To see a list of
help subject use `help help`. The script will attemp to do a regexp
match if you do provide the exact help topic, so you can cheat and use
shortened versions of the topic.

    help cloudwatch

### apply

Reads the configuration file and determines what actions to perform
and what resources will be built.  Builds resources incrementally and
updates configuration file with resource details.

### create-service

    create-service service-name

When you provision an HTTP, HTTPS or daemon service the framework
provisions all of the components for you to execute the task. It
**does not** however, start the service. Use this command to create and
start the service.

    app-FargateTask start-service service-name

If you want to provision more than 1 task for your service add a count argument.

    app-FargateTask start-service service-name 2

### delete-service

    delete-service service-name

This command will delete a service. If you just want to temporarily
stop the service use the `stop-service` command.

### disable-scheduled-task

    disable-scheduled-task task-name

Use this command to disable a scheduled task.

If you omit `task-name`, the command will attempt to determine the
target task selecting the task of type `task` with a defined
`schedule:` key but only if exactly one such task is defined in
your configuration file.

### enable-scheduled-task

    enable-scheduled-task task-name

Use this command to enable a scheduled task.

If you omit `task-name`, the command will attempt to determine the
target task selecting the task of type `task` with a defined
`schedule:` key but only if exactly one such task is defined in
your configuration file.

### list-tasks

Lists running tasks and outputs a table of information about the tasks.

    Task Name
    Task Id
    Status
    Memory
    CPU
    Start Time
    Elapsed Time

### list-zones

    list-zones domain-name

This command will list the hosted zones for a specific domain. The
framework automatically detects the appropriate hosted zone for your
domain if the `zone_id:` key is missing from your configuration when
you have an HTTP or HTTPS task defined.

Example:

    app-FargateStack list-zones --profile prod

### logs

    logs start-time end-time

To view your log streams use the `logs` command. This command will
display the logs for the most recent log stream in the log group. By
default the start time is the time of the first event.

- Use `--log-wait` to continuously poll the log stream.
- Use `--no-log-time` if your logs already have timestamps and do
not want to see CloudWatch timestamps. This is useful when you are
logging time in your time zone and do not want to be confused seeing
times that don't line up.
- `start-time` can be a "Nh", "Nm", "Nd" where N is an integer
and h=hours ago, m=minutes ago and d=days ago.
- `start-time` and `end-time` can be "mm/dd/yyyy hh:mm:ss" or just "mm/dd/yyyy"
- `end-time` must always be a date-time string.

### plan              

Reads the configuration file and determines what actions to perform
and what resources will be built. Only updates configuration file with
resource details but DOES NOT build them.

### redeploy

    redeploy service-name

Forces a new deployment of the specified ECS service without registering a new
task definition. This triggers ECS to stop the currently running task and
launch a new one using the same task definition revision.

If you omit `service-name`, the command will attempt to determine the
target service by selecting the task of type `daemon`, `http`, or
`https`, but only if exactly one such service is defined in your
configuration file.

If the task definition references an image by tag (such as `:latest`), this
command ensures ECS re-pulls the image from ECR at deployment time. This allows
you to deploy a newly pushed image without needing to create a new revision of
the task definition.

This command is especially useful when:

- You have pushed a new version of an image using the same tag (e.g. `:latest`)
- You want to roll the service without changing other configuration
- You want to confirm ECS tasks are using the most up-to-date image tag from ECR

Note that if your task definition references an image by digest
(e.g. `@sha256:...`), ECS will continue to use that exact image. In that case,
you must register a new task definition to update the image.

For best results, use this command only when your service’s task definition
uses an image tag that can be re-resolved, such as `:latest` or a CI-generated
version tag.

### run-task

    run-task task-name

Launches a one-shot Fargate task. By default, the command waits for the
task to complete and streams the task’s logs to STDERR. Use the `--no-wait`
option to launch the task and return immediately.

When you register a task definition, ECS records the image digest of the
image specified in your configuration file. If you later push a new image
tagged with the same name (e.g., `latest`) without updating the task
definition, ECS will continue to use the original image digest.

To detect this kind of drift, `app-FargateStack` records the image digest
at the time of task registration and compares it to the current digest
associated with the tag (typically `latest`) at runtime.

If the digests do not match, the default behavior is to abort execution
and warn you about the mismatch. To override this safety check and proceed
anyway, use the `--force` option.

### status

    status service-name

Displays the status of a running service and its most recent event messages
in tabular form.

If you omit `service-name`, the command will attempt to determine the
target service by selecting the task of type `daemon`, `http`, or
`https`, but only if exactly one such service is defined in your
configuration file.

Use the `--max-events` option to control how many recent events are shown.
The default is 5.

### stop-task

    stop-task task-arn|task-id

Stops a running task. To get the task id, use the `list-tasks`
command.

### stop-service

    stop-service service-name

Stops a running service by setting its desire count to 0.

If you omit `service-name`, the command will attempt to determine the
target service by selecting the task of type `daemon`, `http`, or
`https`, but only if exactly one such service is defined in your
configuration file.

### start-service

    start-service service-name [count]

Start a service. `count` is the desired count of tasks. The default
count is 1.

If you omit `service-name`, the command will attempt to determine the
target service by selecting the task of type `daemon`, `http`, or
`https`, but only if exactly one such service is defined in your
configuration file.

### update-policy

    update-policy

Forces the framework to re-evaluate resources and align the
policy. Will not apply changes in `--dryrun` mode. Under normal
circumstances you should not need to run this command, however if you
find that your Fargate policy lacks permissions for resources you have
configure, this will make sure that all configured resources are
included in your policy.

If `update-policy` identifies a need to update your role policy, you
can view the changes before they are applied by running the `plan` command at the `trace` log level.

    app-Fargate --log-level trace plan

### update-target

    update-target task-name

Updates an EventBridge rule and rule target. For tasks of type "task"
(typically scheduled jobs) when you change the schedule the rule must
be deleted, re-created and associated with the target task. This
command will detect the drift in your configuration and apply the
changes if not in `--dryrun` mode.

### version              

Outputs the current version of `App::FargateStack`.

[Back to Table of Contents](#table-of-contents)

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

- ...create a log group named /ecs/my-stack
- ...configure the apache task to write log streams with a prefix
like my-stack/apache/\*

By default, the log group is set to retain logs for 14 days if
`retention_days` is not specified. You can override this by
specifying a custom retention period using the `retention_days` key
in the task's log\_group section:

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

[Back to Table of Contents](#table-of-contents)

# IAM PERMISSIONS

This framework uses a single IAM role for all tasks defined within an
application stack.  The assumption is that services within the stack
share a trust boundary and operate on shared infrastructure.  This
simplifies IAM management while maintaining strict isolation between
stacks.

IAM roles and policies are automatically created based on your
configuration.  Only the minimum required permissions are granted.
For example, if your configuration defines an S3 bucket, the ECS task
role will be permitted to access only that specific bucket - not all
buckets in your account. The policy is updated when new resources are
added to the configuration file.

The role name an role policy name are found under the `role:` key in
the configuration. A role name and role policy name are automatically
fabricated for you from the name you specified under the `app:` key.

[Back to Table of Contents](#table-of-contents)

# SECURITY GROUPS

A security group is automatically provisioned for your Fargate
cluster.  If you define a task of type `http` or `https`, the
security group attached to your Application Load Balancer (ALB) is
automatically authorized for ingress to your Fargate task. This is a
rule allowing ALB-to-Fargate traffic.

[Back to Table of Contents](#table-of-contents)

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

Acceptable values for `readonly` are "true" and "false".

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
`efs:` section to "true" if only want read support.
- Your EFS security group must allow access from private subnets
where the Fargate tasks are placed.
- No changes are made to the EFS security group; the framework
assumes access is already configured
- Only one EFS volume is currently supported per task configuration.
- EFS volumes are task-scoped and reused only where explicitly configured.
- The framework does not automatically provision an EFS
filesystem for you. The framework does however validate that the
filesystem exists in the current account and region.

[Back to Table of Contents](#table-of-contents)

# CONFIGURATION

The `App::FargateStack` framework defines your application stack
using a YAML configuration file. This file describes your
application's services, their resource needs, and how they should be
deployed. Then configuration is updated whenever your run `plan` or
`apply`.

## GETTING STARTED

Start by creating a minimal YAML configuration file with the required sections:

    app:
      name: my-stack

    tasks:
      my-stack-daemon-1:
        image: my-stack-daemon:latest
        type: daemon

Each task represents a containerized service that you want to run. In this example,
the framework will provision:

- a Fargate cluster in the `us-east-1` region
- one daemon service
- networking in the default VPC using a private subnet
- any required AWS resources using the default profile (or the one specified in `AWS_PROFILE`)

Once configured, run:

    app-FargateStack plan

This will analyze your configuration and report what will be created. It will also
update the file with any discovered defaults. To apply the plan and provision the
stack, run:

    app-FargateStack -c my-stack.yml apply

**You do not need to specify every setting up front. The framework will attempt to
auto-discover certain AWS resources if they are not configured.**

## VPC AND SUBNET DISCOVERY

If you do not specify a `vpc_id` in your configuration, the framework will attempt
to locate a usable VPC automatically.

A VPC is considered usable if it meets the following criteria:

- It is attached to an Internet Gateway (IGW)
- It has at least one available NAT Gateway

If no eligible VPCs are found, the process will fail with an error. If multiple
eligible VPCs are found, the framework will abort and list the candidate VPC IDs.
You must then explicitly set the `vpc_id:` in your configuration to resolve
the ambiguity.

If exactly one eligible VPC is found, it will be used automatically,
and a warning will be logged to indicate that the selection was
inferred.

## SUBNET SELECTION

If no subnets are specified in the configuration, the framework will query all
subnets in the selected VPC and categorize them as either public or private.

The task will be placed in a private subnet by default. For this to succeed,
your VPC must have at least one private subnet with a route to a NAT Gateway,
or have appropriate VPC endpoints configured for ECR, S3, STS, CloudWatch Logs,
and any other services your task needs.

If subnets are explicitly specified in your configuration, the
framework will validate them and warn if they are not reachable or are
not usable for Fargate tasks.

## REQUIRED SECTIONS

At minimum, your configuration must include the following:

    app:
      name: my-stack

    tasks:
      my-task:
        image: my-image
        type: daemon | task | http | https

For task types `http` or `https`, you must also specify a domain name:

    domain: example.com

## FULL SCHEMA OVERVIEW

The framework will expand and update your configuration file with default values as needed.
Here is the full schema outline. All keys are optional unless otherwise noted:

    ---
    account:
    alb:
      arn:
      name:
      port:
      type:
    app:
      name:             # required
      version:
    certificate_arn:
    cluster:
      arn:
      name:
    default_log_group:
    domain:              # required for http/https tasks
    id:
    last_updated:
    region:
    role:
      arn:
      name:
      policy_name:
    route53:
      profile:
      zone_id:
    security_groups:
      alb:
        group_id:
        group_name:
      fargate:
        group_id:
        group_name:
    subnets:
      private:
      public:
    tasks:
      my-task:
        arn:
        cpu:
        family:
        image:           # required
        log_group:
          arn:
          name:
          retention_days:
        memory:
        name:
        target_group_arn:
        target_group_name:
        task_definition_arn:
        type:            # required (daemon, task, http, https)
    vpc_id:

# ENVIRONMENT VARIABLES

The Fargate stack framework allows you to define environment variables for each
task. These variables are included in the ECS task definition and made available
to your container at runtime.

Environment variables are specified under the `environment:` key within the task
configuration.

## BASIC USAGE

    task:
      apache:
        environment:
          ENVIRONMENT: prod
          LOG_LEVEL: info
          DEBUG_MODE: 0

Each key/value pair will be passed to the container as an environment
variable.

Environment variable values are treated literally; shell-style
expressions such as ${VAR} are not interpolated. If you need dynamic
values, populate them explicitly in the configuration or use the
`secrets:` block for sensitive data.

This mechanism is ideal for non-sensitive configuration such as
runtime flags, environment names, or log levels.

## SECURITY NOTE

Avoid placing secrets (such as passwords, tokens, or private keys) directly in the
`environment:` section. That mechanism is intended for non-sensitive configuration
data.

To securely inject secrets into the task environment, use the `secrets:` section
of your task configuration. This integrates with AWS Secrets Manager and ensures
secrets are passed securely to your container.

## INJECTING SECRETS FROM SECRETS MANAGER

To inject secrets into your ECS task from AWS Secrets Manager, define a `secrets:`
block in the task configuration. Each entry in this list maps a Secrets Manager
secret path to an environment variable name using the following format:

    /secret/path:ENV_VAR_NAME

Example:

    task:
      apache:
        secrets:
          - /my-stack/mysql-password:DB_PASSWORD

This configuration retrieves the secret value from `/my-stack/mysql-password`
and injects it into the container environment as `DB_PASSWORD`.

Secrets are referenced via their ARN using ECS's native secrets mechanism,
which securely injects them without placing plaintext values in the task definition.

## BEST PRACTICES

Avoid placing secrets in the `environment:` block. That block is for non-sensitive
configuration values and exposes data in plaintext.

Use clear, descriptive environment variable names (e.g., `DB_PASSWORD`, `API_KEY`)
and organize your Secrets Manager paths consistently with your stack naming.

[Back to Table of Contents](#table-of-contents)

# SQS QUEUES

The Fargate stack framework supports configuring and provisioning a
single AWS SQS queue, including an optional dead letter queue (DLQs).

A queue is defined at the stack level and is accessible to all tasks
and services within the same stack. IAM permissions are automatically
scoped to include only the explicitly configured queue and its
associated DLQ (if any).

_Only one queue and one optional DLQ may be configured per stack._

## BASIC CONFIGURATION

At minimum, a queue requires a name:

    queue:
      name: fu-man-q

If you define `max_receive_count` in the queue configuration, a DLQ
will be created automatically. You can optionally override its name
and attributes using the top-level `dlq` key:

    queue:
      name: fu-man-q
      max_receive_count: 5

    dlq:
      name: custom-dlq-name

If you do not specify a `dlq.name`, the framework defaults to appending `-dlq` to
the main queue name (e.g., `fu-man-q-dlq`).

## DEFAULT QUEUE ATTRIBUTES

If not specified, the framework applies default values to match AWS's standard SQS behavior:

    queue:
      name: fu-man-q
      visibility_timeout: 30
      delay_seconds: 0
      receive_message_wait_time_seconds: 0
      message_retention_period: 345600
      maximum_message_size: 262144
      max_receive_count: 5  # triggers DLQ creation

    dlq:
      visibility_timeout: 30
      delay_seconds: 0
      receive_message_wait_time_seconds: 0
      message_retention_period: 345600
      maximum_message_size: 262144

## DLQ DESIGN NOTE

A dead letter queue is not a special type - it is simply another queue used
to receive messages that have been unsuccessfully processed. It is modeled
as a standalone queue and defined at the top level of the stack configuration.

The `dlq` block is defined at the same level as `queue`, not nested within it.
If no overrides are provided, DLQ attributes default to AWS attribute defaults.

## IAM POLICY UPDATES

Adding a new queue to an existing stack will not only create the queue, but
also update the IAM policy associated with your stack to include permissions
for the newly defined queue and DLQ (if applicable).

[Back to Table of Contents](#table-of-contents)

# SCHEDULED JOBS

The Fargate stack framework allows you to schedule container-based jobs
using AWS EventBridge. This is useful for recurring tasks like report generation,
batch processing, database maintenance, and other periodic workflows.

A scheduled job is defined like any other task, using `type: task`, and
adding a `schedule:` key in AWS EventBridge cron format.

## SCHEDULING A JOB

To schedule a job, add a `schedule:` key to your task definition. The
value must be a valid AWS cron expression, such as:

    cron(0 2 * * ? *)   # every day at 2:00 AM UTC

Example:

    tasks:
      daily-report:
        type: task
        image: report-runner:latest
        schedule: cron(0 2 * * ? *)

_Note: All cron expressions are interpreted in UTC._

The framework will automatically create an EventBridge rule tied to
the task definition. When triggered, it will launch a one-off Fargate
task based on the configuration. The EventBridge rule is named using
the pattern "&lt;task>-schedule".

All scheduled tasks support environment variables, secrets, and other
standard task features.

## RUNNING AN ADHOC JOB

You can run a scheduled (or unscheduled) task manually at any time using:

    app-FargateStack run-task task-name

By default, this will:

- Launch the task using the defined image and configuration
- Wait for the task to complete (unless `--no-wait` is passed)
- Retrieve and print the logs from CloudWatch when the task exits

This is ideal for debugging, re-running failed jobs, or triggering
occasional maintenance tasks on demand.

## SERVICES VS TASKS

A task of type `daemon` is launched as a long-running ECS service
and benefits from restart policies and availability guarantees.

A task of type `task` is run using `run-task` and may run once,
forever, or periodically - but it will not be automatically restarted
if it fails.

[Back to Table of Contents](#table-of-contents)

# S3 BUCKETS

The Fargate stack framework supports creating a new S3 bucket or
using an existing one. The bucket can be used by your ECS tasks
and services, and the framework will configure the necessary IAM
permissions for access.

By default, full read/write access is granted unless you specify
restrictions (e.g., read-only or path-level constraints). In this model,
no bucket policy is required or modified.

_Note: Full access includes s3:GetObject, s3:PutObject, s3:DeleteObject, and
s3:ListBucket.  Readonly access is limited to s3:GetObject and
s3:ListBucket._

## BASIC CONFIGURATION

You define a bucket in your configuration like this:

    bucket:
      name: my-app-bucket

By default, this grants full read/write access to the entire bucket via the
IAM role attached to your ECS task definition.

## RESTRICTED ACCESS

You can limit access to a subset of the bucket using the `readonly:` and
`paths:` keys:

    bucket:
      name: my-app-bucket
      readonly: true
      paths:
        - public/*
        - logs/*

This will:

- Grant only `s3:GetObject` and `s3:ListBucket` permissions
- Limit access to the specified path prefixes

The `paths:` values are interpreted as S3 key prefixes and inserted
directly into the role policy.

If you specify `readonly: true` but omit `paths:`, read-only access will
apply to the entire bucket. If you omit both keys, full read/write access
is granted.

## IAM-BASED ENFORCEMENT

Bucket access is enforced exclusively through IAM role permissions. The
framework does not modify or require an S3 bucket policy. This keeps your
configuration simpler and avoids potential conflicts with externally
managed bucket policies.

## USING EXISTING BUCKETS

If you reference an existing bucket not created by the framework, be aware
that the bucket's own policy may still restrict access.

In particular:

- The IAM role created by the framework may permit access to a path
- But a bucket policy with an explicit `Deny` will override that and block access
- This restriction will only be discovered at runtime when your task attempts access

To avoid surprises, ensure that any bucket policy on an external bucket
permits access from the IAM role you're configuring.

[Back to Table of Contents](#table-of-contents)

# HTTP SERVICES

## Overview

To create a Fargate HTTP service set the `type:` key in your task's
configuration section to "http" or "https".

The task type ("http" or "https") determines:

- the **type of load balancer** that will be used or created
- whether or not a **certificate will be used or created**
- what **default port** will be configured in your ALB's listener
rule

## Key Assumptions When Creating HTTP Services

- Your domain is managed in Route 53 and your profile can create
Route 53 record sets.

    _Note: If your domain is managed in a different AWS account, set a
    separate `profile:` value in the `route53:` section of the
    configuration file.  Your profile should have sufficient permissions
    to manage Route 53 recordsets._

- Your Fargate task will be deployed in a private subnet and
will listen on port 80.
- No certificate will be provisioned for internal facing
applications. Traffic by default to internal facing applications
(those that use an internal ALB) will be insecure. _This may become
an option in the future._

## Architecture

When you set your task type to "http" or "https" a default
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
deployment pattern for HTTP services with minimal configuration.

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
both a **private** and **public** hosted zone for your domain._

Your task type will also determine which type of subnet is required
and where to search for an existing ALB to use. If you want to prevent
re-use of an existing ALB and force the creation of a new one use the
`--create-alb` option when you run your first plan.

In your initial configuration you do not need to specify the subnets
or the hosted zone id.  The framework will discover those and report
if any required resources are unavailable. If the task type is
"https", the script looks for a public zone, public subnets and an
internet-facing ALB otherwise it looks for a private zone, private
subnets and an internal ALB.

## ACM Certificate Management

If the task type is "https" and no ACM certificate currently exists
for your domain, the framework will automatically provision one. The
certificate will be created in the same region as the ALB and issued
via AWS Certificate Manager. If the certificate is validated  via DNS
and subsequently attached to the listener on port 443.

## Port and Listener Rules

For external-facing apps, a separate listener on port 80 is
created. It forwards traffic to port 443 using a default redirect rule
(301). If you do not want a redirect rule, set the `redirect_80:` in
the `alb:` section to "false".

If you want your internal application to listen on a port other than
80, set the `port:` key in the `alb:` section to a new port
value.

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
your HTTP service.

To do that, the framework attempts to discover the resources required
for your service. If your environment is not compatible with creating
the service, the framework will report the missing resources and
abort the process.

Given this minimal configuration for an internal ("http") or
external ("https") HTTP service, discovery entails:

- ...determining your VPC's ID
- ...identifying the private subnet IDs
- ...determining if there is and existing load balancer with the
correct scheme
- ...finding your load balancer's security group (if an ALB exists)
- ...looking for a listener rule on port 80 (and 443 if type is
"https"), including a default forwarding redirect rule
- ...validating that you have a private or public hosted zone
in Route 53 that supports your domain
- ...setting other defaults for additional resources to be built (log
groups, cluster, target group, etc)
- ...determining if an ACM certificate exists for your domain
(if type is "https")

_Note: Discovery of these resources is only done when they are
missing from your configuration. If you have multiple VPCs for example
you can should explicitly set `vpc_id:` in the configuration to
identify the target VPC.  Likewise you can explicitly set other
resource configurations (subnets, ALBs, Route 53, etc)._

Resources are provisioned and your configuration file is updated
incrementally as `app-FargateStack` compares your environment to the
environment required for your stack. When either plan or
apply complete your configuration is updated giving you complete
insight into what resources were found and what resources will be
provisioned. See [CONFIGURATION](https://metacpan.org/pod/CONFIGURATION) for complete details on resource
configurations.>

Your environment will be validated against the criteria described
below.

- You have at least 2 private subnets available for deployment

    Technically you can launch a task with only 1 subnet but for services
    behind an ALB Fargate requires 2 subnets.

    _When you create a service with a load balancer, you must specify
    two or more subnets in different Availability Zones. - AWS Docs_

- You have a hosted zone for your domain of the appropriate type
(private for type "http", public for type "https")

As discovery progresses, existing and required resources are logged
and your configuration file is updated. If you are **NOT** running in
dryrun mode, resources will be created immediately as they are
discovered to be missing from your environment.

## Application Load Balancer

When you provision an HTTP service, whether or not it is secure, the
service will placed behind an application load balancer. Your Fargate
service is created in private subnets, so your VPC must contain at
least two private subnets.  Your load balancer can either be
_internally_ or _externally facing_.

By default, the framework looks for and will reuse a load balancer
with the correct scheme (internal or internet-facing), in a subnet
aligned with your task type. The ALB will be placed in public subnets
if it is internet-facing. You can override that behavior by either
explicitly setting the ALB arn in the `alb:` section of the
configuration or pass `--create-alb` when you run our plan and apply.

If no ALB is found or you passed the `--create-alb` option, a new ALB
is provisioned. When creating a new ALB, `app-FargateStack` will also
create the necessary listeners and listener rules for the ports you
have configured.

### Why Does the Framework Force the Use of an Load Balancer?

While it is possible to avoid the use or the creation of a load balancer
for your service, the framework forces you to use one for at least two
reasons. Firstly, the IP address of your service may not be stable and
is not friendly for development or production purposes. The framework
is, after all trying its best to promote best practices while
preventing you from having to know how all the sausage is made.

Secondly, it is almost guaranteed that you will eventually want
a domain name for your production service - whether it is an
internally facing microservice or an externally facing web
application.

Creating an alias in Route 53 for your domain pointing to the ALB
ensures you don't need to update application configurations with the
service's dynamic IP address. Additionally, using a load balancer
allows you to create custom routing rules to your service. If you want
to run multiple tasks for your service to support handling more
traffice a load balancer is required.

With those things in mind the framework automatically uses an ALB for
HTTP services and creates an alias record (A) for your domain for both
internal and external facing services.

## Roadmap for HTTP Services

- path based routing on ALB listeners
- Auto-scaling policies

[Back to Table of Contents](#table-of-contents)

# CURRENT LIMITATIONS

- Stacks may contain multiple daemon services, but only one task
may be exposed as an HTTP/HTTPS service via an ALB.
- Limited configuration options for some resources such as
advanced load balancer listener rules, custom CloudWatch metrics, or
task health check tuning.
- Some out of band infrastructure changes may break the ability
to re-run `app-FargateStack` without manually updating the
configuration
- Support for only 1 EFS filesystem per task

[Back to Table of Contents](#table-of-contents)

# TROUBLESHOOTING

## Why is my task or service still using an old image?

This is one of the most common points of confusion when working with
ECS and Fargate.

You may have just built and pushed a new image to ECR using the same
tag (e.g. `latest`), but when you launch a task or deploy a service,
ECS appears to continue using the old image.  Here’s why.

### One-off tasks: `run-task` uses a fixed image digest

When you run a task using:

    app-FargateStack run-task my-task

ECS uses the exact task definition revision as registered. If the
image was specified using a tag like `:latest`, ECS resolves that tag
once—at the time the task starts—and stores the resolved digest
(e.g. `sha256:...`).

This means:

- Tasks launched this way will continue to run the old image, even if
the `latest` tag in ECR now points to a newer image.
- The only way to run a task with the new image is to register a new
task definition that references the updated image. You can force a new
task definition by registering the definition.

        app-FargateStack register my-task

### Services: `create-service` and `update-service` use frozen images too

When you create or update a service, ECS also resolves any image tags
to their current digest and stores that in the registered task
definition.

This means that ECS services are also tied to the image that existed
at the time of task definition registration.

If you push a new image to ECR using the same tag (e.g. `:latest`),
the service will not automatically use it.  ECS does not re-resolve
the tag unless you explicitly tell it to.

### `--force-new-deployment` re-pulls image tags (if not pinned by digest)

If your task definition references the image by tag
(e.g. `http-service:latest`), and not by digest, then running:

    app-FargateStack redeploy my-service

will cause ECS to:

- Stop the currently running tasks
- Start new tasks using the same task definition revision
- Re-resolve and pull the image tag from ECR

This allows your service to pick up a newly pushed image without
registering a new task definition, as long as the task definition used
a tag (not a digest).

### Confirm what your task definition is using

To see whether your task definition uses a tag or a digest, run:

    aws ecs describe-task-definition --task-definition my-task:42

Look at the `image` field under `containerDefinitions`. It will either be:

    image: http-service:latest     # tag — will be re-resolved by --force-new-deployment
    image: http-service@sha256:... # digest — frozen, cannot be re-resolved

### Best practices

- Avoid using `:latest` in production. Use immutable tags
(e.g. `:v1.2.3`) or digests.
- If you want to deploy a new image, the safest and most deterministic approach is to:

        - Build and push the image using a new tag or digest
        - Register a new task definition revision referencing that tag or digest
        - Update your service to use the new task definition

- Use `--force-new-deployment` only if your task definition uses a tag
and you want to re-resolve it without changing the task definition
itself.

[Back to Table of Contents](#table-of-contents)

# ROADMAP

- destroy {task-name}

    Destroy all resources for all tasks or for one task. Buckets and
    queues will not be deleted.

- scaling configuration
- Add support for more advance configuration options for some
resources

[Back to Table of Contents](#table-of-contents)

# SEE ALSO

[IPC::Run](https://metacpan.org/pod/IPC%3A%3ARun), [App::Command](https://metacpan.org/pod/App%3A%3ACommand), [App::AWS](https://metacpan.org/pod/App%3A%3AAWS), [CLI::Simple](https://metacpan.org/pod/CLI%3A%3ASimple)

[Back to Table of Contents](#table-of-contents)

# AUTHOR

Rob Lauer - rclauer@gmail.com

[Back to Table of Contents](#table-of-contents)

# LICENSE

This script is released under the same terms as Perl itself.

# POD ERRORS

Hey! **The above document had some coding errors, which are explained below:**

- Around line 749:

    Non-ASCII character seen before =encoding in 'service’s'. Assuming UTF-8
