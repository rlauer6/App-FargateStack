# Examples

This directory contains minimal configurations required for several
Fargate tasks.

| Task Type | Configuration | Image | Description |
| --------- | ------------- | ----- | ----------- |
|   task    | minimal-task.yml | hellworld | One-shot task |
|   task    | minimal-scheduled-task.yml | helloworld | Scheduled task |
|   daemon  | minimal-daemon.yml | helloworld | Long running service |
| http | minimal-http.yml | http-test | HTTP service |
| https | minimal-https.yml | http-test | HTTPS service |

# How to Run the Test Tasks

## One-shot Jobs

The `minimal-task.yml` configuration implements a one-shot workload
type task. You can run this at any time after you build the cluster.

```
app-FargateStack -c minimal-task.yml plan
app-FargateStack -c minimal-task.yml apply
app-FargateStack -c minimal-task.yml run-task
```

One-shot jobs will log the provisioning steps to the console and wait
for the job to complete. Once the job is done the logs will be
displayed on the console.

`app-FargateTask` will be default place your workload in one of the
private subnet discovered or provided by you in the configuration
file.  If it cannot find a private subnet it will try to run the task
in a public subnet.  You can set the subnet for placement using the
C<--subnet-id> option when you run the task.  Whichever subnet is
chosen, must have a way to pull images from ECR.  That is usually
implemented usint a NAT gateway in private subnets or an internet
gateway in public subnets. It's also possible to use VPC endpoints.
See the [VPC AND SUBNET DISCOVERY](https://github.com/rlauer6/App-FargateStack/tree/main?tab=readme-ov-file#vpc-and-subnet-discovery) section of the main README file
for more information.

## Scheduled Jobs

The `minimal-scheduled-task.yml` will create a scheduled job that runs
the `helloworld` image. Check the logs after the job has run:

```
app-FargateStack -c minimal-schedule-task.yml logs my-cron-job 1d
```


