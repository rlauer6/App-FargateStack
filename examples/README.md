# Examples

This directory contains several **minimal configurations** used to
test different Fargate task types. Use these configurations together
with the Docker images that can be built in the [`/docker`](../docker)
directory to try out the framework.

| Task Type | Configuration                | Image       | Description         |
|-----------|------------------------------|-------------|---------------------|
| task      | minimal-task.yml             | helloworld  | One-shot task       |
| task      | minimal-scheduled-task.yml   | helloworld  | Scheduled task      |
| daemon    | minimal-daemon.yml           | helloworld  | Long-running task   |
| http      | minimal-http.yml             | http-test   | HTTP service        |
| https     | minimal-https.yml            | http-test   | HTTPS service       |

---

# Minimal Configurations for Tasks

Assuming your AWS account includes a VPC with internet access, the
power of `App::Fargate` lies in its ability to provision a fully
functional Fargate task with just a few key inputs -- depending on the
type of workload you want to deploy.

In most cases, you need to provide only three pieces of information:

- The application name
- The ECR image name
- The deployment type (`task`, `http`, or `https`)

Once provided, `App::Fargate` will analyze your environment, discover
the necessary AWS resources (like subnets, security groups, and IAM
roles), and generate a complete configuration by filling in any
missing details. You'll be able to review and customize the generated
values before running the `apply` command to launch your task.

| Task Type         | Required Values |
|-------------------|-----------------|
| task              | 3               |
| task (scheduled)  | 4               |
| daemon            | 3               |
| http              | 4               |
| https             | 4               |

Below you'll find a breakdown of each task type, along with the
minimal configuration required to get started.

## One-shot Jobs

The `minimal-task.yml` configuration defines a one-shot (ephemeral)
workload. 

---
app:
  name: my-one-shot
tasks:
  my-one-shot:
    type: task
    image: helloworld:latest

You can run this task at any time after your cluster has
been created:

```sh
app-FargateStack -c minimal-task.yml plan
app-FargateStack -c minimal-task.yml apply
app-FargateStack -c minimal-task.yml run-task
```

The task will log its provisioning steps to the console and wait for
completion. Once finished, logs will be streamed to your terminal.

By default, `app-FargateStack` will place the task in a private subnet
discovered from your configuration or provided explicitly. If no
private subnet is found, it falls back to a public subnet.

You can override the subnet selection using the `--subnet-id` option
when launching the task.

Whichever subnet is used, it **must have network access to pull images
from ECR**, which is typically provided by:

* A **NAT gateway** (for private subnets)
* An **Internet gateway** (for public subnets)
* **VPC endpoints** configured for ECR

See the [VPC AND SUBNET
DISCOVERY](https://github.com/rlauer6/App-FargateStack/tree/main?tab=readme-ov-file#vpc-and-subnet-discovery)
section of the main README for more information.

---

## Scheduled Jobs

The `minimal-scheduled-task.yml` file defines a scheduled job that runs the `helloworld` image:

```yaml
---
app:
  name: my-cron-job
tasks:
  my-cron-job:
    type: task
    image: helloworld:latest
    schedule: cron(00 15 * * * *)
    environment:
      RUN_ONCE: 1
```

A task becomes a scheduled job when its definition includes both a
`type: task` and a `schedule:` key within the task configuration. The
`schedule:` follows the Amazon EventBridge cron format.

See [AWS Schedule
Expressions](https://docs.aws.amazon.com/scheduler/latest/UserGuide/schedule-types.html#cron-based)
for format details.

To deploy the scheduled job:

```sh
app-FargateStack -c minimal-scheduled-job plan
app-FargateStack -c minimal-scheduled-job apply
```

Check the logs after execution:

```sh
app-FargateStack -c minimal-scheduled-task.yml logs my-cron-job 1d
```

> **NOTE**: Scheduled jobs can also be launched manually using `run-task`.

---

## Long-running Tasks

There are two kinds of tasks that `app-FargateStack` will deploy as
services. To deploy a continuously running task, set `type: daemon` in
your configuration:

```yaml
---
app:
  name: my-daemon
tasks:
  my-daemon:
    type: daemon
    image: helloworld:latest
```

These are often used to respond to events such as messages in SQS or
new files in S3/EFS.

Your application must keep running and should only exit on failure. If
it does exit, ECS will automatically restart it.

---

## HTTP Services

Use the `http` or `https` type to deploy a container behind an
application load balancer:

```yaml
---
app:
  name: http-test
domain: http-test.example.com
tasks:
  http-test:
    type: http
    image: http-test:latest
```

* `http` services are internal and attached to an internal ALB
* `https` services are external and attached to an internet-facing ALB

Both types will result in a DNS alias being created in Route 53.

See the [HTTP
SERVICES](https://github.com/rlauer6/App-FargateStack/tree/main?tab=readme-ov-file#http-services)
section of the root README for more.

---

# Test Images

The [`/docker`](../docker) directory contains a `Makefile` to build
the following test images:

### `helloworld`

A simple Perl script (`HelloWorld.pl`):

* If `RUN_ONCE=1`, it exits after dumping the environment
* Otherwise, it loops indefinitely

Useful for testing one-shot, daemon, and scheduled task types.

### `http-test`

An Apache server running on Debian (bookworm). It listens on port 80
and serves the default Apache test page.

---

## Building and Installing the Images

>️**WARNING**: This will create AWS resources that may incur costs.

To build the test images:

```sh
AWS_PROFILE=my-profile make images
```

To push them to ECR:

```sh
AWS_PROFILE=my-profile make install
```

> `make install` will:
>
> * Tag the images
> * Create ECR repositories (`helloworld`, `http-test`) if they don't exist
> * Push the images to ECR

You must have sufficient permissions to create repositories and push images.

To clean up local images and temp files:

```sh
make realclean
```

---

# Testing

| Task Config                  | Command(s)                         |
| ---------------------------- | ---------------------------------- |
| `minimal-task.yml`           | `plan`, `apply`                    |
| `minimal-scheduled-task.yml` | `plan`, `apply`                    |
| `minimal-daemon.yml`         | `plan`, `create-service my-daemon` |
| `minimal-http.yml`           | `plan`, `create-service apache`    |
| `minimal-https.yml`          | `plan`, `create-service apache`    |

Example:

```sh
app-FargateStack -c minimal-task.yml plan
app-FargateStack -c minimal-task.yml apply
```
