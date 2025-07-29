# Fargate is Farout!

The primary motivation behind writing the `App::FargateStack`
framework was to make provisioning Fargate tasks _simple, fast and
easy_.

```
app:
  name: my-stack
tasks:
  my-daemon:
    image: mycorp/worker:latest
    type: daemon
```

...then

```
app-FargateStack --config my-stack.yml apply
```

Making it easy is also a way to promote the wider use of this
amazingly versatile service.

There are many tools and resources available to developers today for
implementing web applications, microservices, daemons, cron jobs
etc. And no doubt, AWS, Microsoft, Google and all the kids out there
are going to be building more.  However, today Fargate can do all of
it and in some cases far cheaper than other solutions.

In my opinion, Fargate is dismissed as a deployment target far too
quickly. It's not unfair to say that a lot of the movement toward
Kubernetes is just bandwagon jumping when simpler solutions exist.

My goal here is to do a bit of evangelizing for Fargate by creating a
production grade tool that will handle 95% of the things IT
departments do. And to be honest, reinforce my belief that Fargate is
a winning solution that I need to adopt more often.

Let's compare Fargate to EC2.

| Feature                  | **AWS Fargate**                                   | **EC2**                                                   |
| ------------------------ | ------------------------------------------------- | --------------------------------------------------------- |
| **Provisioning**         | Fully managed — no server provisioning            | Manual — you provision and manage EC2 instances           |
| **Scaling**              | Auto-scales per task definition                   | You manage autoscaling groups or scale manually           |
| **Networking**           | Integrated with ECS networking (ENIs per task)    | You configure instance-level networking and security      |
| **IAM Permissions**      | Per-task IAM roles                                | Instance-level IAM roles (must proxy for containers)      |
| **Pricing Model**        | Pay per task vCPU and memory                      | Pay per instance uptime, regardless of usage              |
| **Startup Time**         | Typically under a minute                          | Several minutes for instance boot, ECS agent registration |
| **Resource Isolation**   | One task per VM (managed by AWS)                  | Multiple containers share the EC2 host                    |
| **Container Management** | Abstracted away (ECS schedules tasks directly)    | You manage Docker/Podman or ECS agent on the instance     |
| **Maintenance Overhead** | None — no OS patching or AMI management           | You are responsible for updates and security patches      |
| **Ideal For**            | Short-lived or scalable microservices, dev stacks | Long-lived, specialized workloads needing more control    |

# Summary

* Fargate excels in simplicity, security isolation, and zero
  infrastructure management — perfect for most containerized
  microservices.
* EC2 provides more control and is cost-effective at scale if you
  fully utilize the instance capacity and manage infrastructure
  efficiently.
* If you're trying to launch containers with minimal setup and solid
  defaults, Fargate is a no-brainer. If you need exotic networking,
  GPU access, or low-level tuning, EC2 might still win.

Now let's look at cost.

# Cost Comparison

| Parameter       | Fargate Task                         | EC2 t3.small            |
| --------------- | ------------------------------------ | ----------------------- |
| Frequency       | Every 15 minutes                     | Always-on               |
| Task Duration   | 1 minute (0.017 hours)               | 24x7                    |
| CPU             | 0.25 vCPU                            | 2 vCPU (burstable)      |
| Memory          | 0.5 GB                               | 2 GB                    |
| Region          | us-east-1                            | us-east-1               |
| Storage         | Ephemeral (Fargate includes this)    | EBS included separately |


*Pricing Sources*

* [AWS Fargate pricing](https://aws.amazon.com/fargate/pricing/)
* [EC2 pricing](https://aws.amazon.com/ec2/pricing/on-demand/)


| Category                  | Fargate (Every 15m)              | EC2 t3.small (Always On)    |
| ------------------------- | -------------------------------- | --------------------------- |
| **Number of runs**        | 96/day x \~30 = 2,880 runs       | Always running              |
| **Total compute time**    | 2,880 x 1m = 48 hours            | 24h x 30d = 720 hours       |
| **vCPU price/hr**         | $0.04048 per vCPU-hr            | N/A                         |
| **Memory price/hr**       | $0.004445 per GB-hr             | N/A                         |
| **Compute cost**          | (0.25 x 48 x $0.04048) = $0.49 | Flat                        |
| **Memory cost**           | (0.5 x 48 x $0.004445) = $0.11 | Flat                        |
| **Total Fargate cost**    | **$0.60**                       | —                           |
| **EC2 on-demand price**   | —                                | **$17.28** (720 x $0.024) |
| **EBS (8GB gp3 default)** | —                                | \~$0.80                    |
| **Total EC2 cost**        | —                                | **$18.08**                 |


|                         | Fargate                | EC2 t3.small        |
| ----------------------- | ---------------------- | ------------------- |
| **Monthly Estimate**    | **\~$0.60**           | **\~$18.08**       |
| **Cheapest For**        | Intermittent workloads | Always-on services  |
| **Billing Granularity** | Per second (1-min min) | Per hour            |
| **Maintenance**         | AWS managed infra      | You patch & monitor |

# Conclusion

If your task runs briefly and infrequently (e.g., 1–5 minutes every
15m), Fargate is far cheaper.

*Use EC2 only if:*

* You need persistent processes or caching
* You need to run >50% of the time
* You want custom software not easily packaged in containers
