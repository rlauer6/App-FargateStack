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

## Scheduled Jobs

The `minimal-scheduled-task.yml` will create a scheduled job that runs
the `helloworld` image. Check the logs after the job has run:

```
app-Fargate -c minimal-schedule-task.yml logs my-cron-job 1d
```
