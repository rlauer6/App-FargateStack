# ./lib/App/ACM.pm.in
./lib/App/ACM.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm

# ./lib/App/AWS.pm.in
./lib/App/AWS.pm: \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/ApplicationAutoscaling.pm.in
./lib/App/ApplicationAutoscaling.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/CloudTrail.pm.in
./lib/App/CloudTrail.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm

# ./lib/App/Command.pm.in
./lib/App/Command.pm: \
    ./lib/App/BenchmarkRole.pm

# ./lib/App/EC2.pm.in
./lib/App/EC2.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/ECR.pm.in
./lib/App/ECR.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm

# ./lib/App/ECS.pm.in
./lib/App/ECS.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/EFS.pm.in
./lib/App/EFS.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm

# ./lib/App/ElbV2.pm.in
./lib/App/ElbV2.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm \
    ./lib/App/EC2.pm

# ./lib/App/Events.pm.in
./lib/App/Events.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack.pm.in
./lib/App/FargateStack.pm: \
    ./lib/App/BenchmarkRole.pm \
    ./lib/App/FargateStack/Autoscaling.pm \
    ./lib/App/FargateStack/Builder.pm \
    ./lib/App/FargateStack/Builder/Autoscaling.pm \
    ./lib/App/FargateStack/Builder/Certificate.pm \
    ./lib/App/FargateStack/Builder/Cluster.pm \
    ./lib/App/FargateStack/Builder/EFS.pm \
    ./lib/App/FargateStack/Builder/Events.pm \
    ./lib/App/FargateStack/Builder/HTTPService.pm \
    ./lib/App/FargateStack/Builder/IAM.pm \
    ./lib/App/FargateStack/Builder/LogGroup.pm \
    ./lib/App/FargateStack/Builder/S3Bucket.pm \
    ./lib/App/FargateStack/Builder/SQSQueue.pm \
    ./lib/App/FargateStack/Builder/Secrets.pm \
    ./lib/App/FargateStack/Builder/SecurityGroup.pm \
    ./lib/App/FargateStack/Builder/Service.pm \
    ./lib/App/FargateStack/Builder/TaskDefinition.pm \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Builder/WafV2.pm \
    ./lib/App/FargateStack/CloudTrail.pm \
    ./lib/App/FargateStack/Constants.pm \
    ./lib/App/FargateStack/CreateStack.pm \
    ./lib/App/FargateStack/Init.pm \
    ./lib/App/FargateStack/Logs.pm \
    ./lib/App/FargateStack/Pod.pm \
    ./lib/App/FargateStack/Route53.pm

# ./lib/App/FargateStack/Autoscaling.pm.in
./lib/App/FargateStack/Autoscaling.pm: \
    ./lib/App/FargateStack/AutoscalingConfig.pm \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/AutoscalingConfig.pm.in
./lib/App/FargateStack/AutoscalingConfig.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder.pm.in
./lib/App/FargateStack/Builder.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/Autoscaling.pm.in
./lib/App/FargateStack/Builder/Autoscaling.pm: \
    ./lib/App/FargateStack/AutoscalingConfig.pm \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/Certificate.pm.in
./lib/App/FargateStack/Builder/Certificate.pm: \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/Cluster.pm.in
./lib/App/FargateStack/Builder/Cluster.pm: \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/EFS.pm.in
./lib/App/FargateStack/Builder/EFS.pm: \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/Events.pm.in
./lib/App/FargateStack/Builder/Events.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/HTTPService.pm.in
./lib/App/FargateStack/Builder/HTTPService.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/IAM.pm.in
./lib/App/FargateStack/Builder/IAM.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/LogGroup.pm.in
./lib/App/FargateStack/Builder/LogGroup.pm: \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/S3Bucket.pm.in
./lib/App/FargateStack/Builder/S3Bucket.pm: \
    ./lib/App/FargateStack/Constants.pm \
    ./lib/App/S3Api.pm

# ./lib/App/FargateStack/Builder/SQSQueue.pm.in
./lib/App/FargateStack/Builder/SQSQueue.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm \
    ./lib/App/SQS.pm

# ./lib/App/FargateStack/Builder/Secrets.pm.in
./lib/App/FargateStack/Builder/Secrets.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm \
    ./lib/App/SecretsManager.pm

# ./lib/App/FargateStack/Builder/SecurityGroup.pm.in
./lib/App/FargateStack/Builder/SecurityGroup.pm: \
    ./lib/App/Events.pm \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/Service.pm.in
./lib/App/FargateStack/Builder/Service.pm: \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/TaskDefinition.pm.in
./lib/App/FargateStack/Builder/TaskDefinition.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Builder/WafV2.pm.in
./lib/App/FargateStack/Builder/WafV2.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm \
    ./lib/App/WafV2.pm

# ./lib/App/FargateStack/Checker.pm.in
./lib/App/FargateStack/Checker.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm

# ./lib/App/FargateStack/CloudTrail.pm.in
./lib/App/FargateStack/CloudTrail.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm

# ./lib/App/FargateStack/CreateStack.pm.in
./lib/App/FargateStack/CreateStack.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Init.pm.in
./lib/App/FargateStack/Init.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/FargateStack/Logs.pm.in
./lib/App/FargateStack/Logs.pm: \
    ./lib/App/FargateStack/Builder/Utils.pm \
    ./lib/App/FargateStack/Constants.pm \
    ./lib/App/Logs.pm

# ./lib/App/FargateStack/Route53.pm.in
./lib/App/FargateStack/Route53.pm: \
    ./lib/App/FargateStack/Constants.pm \
    ./lib/App/Route53.pm

# ./lib/App/IAM.pm.in
./lib/App/IAM.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm

# ./lib/App/Logs.pm.in
./lib/App/Logs.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/Route53.pm.in
./lib/App/Route53.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/S3Api.pm.in
./lib/App/S3Api.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm

# ./lib/App/SQS.pm.in
./lib/App/SQS.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm \
    ./lib/App/FargateStack/Constants.pm

# ./lib/App/STS.pm.in
./lib/App/STS.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm

# ./lib/App/SecretsManager.pm.in
./lib/App/SecretsManager.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm

# ./lib/App/WafV2.pm.in
./lib/App/WafV2.pm: \
    ./lib/App/AWS.pm \
    ./lib/App/Command.pm

