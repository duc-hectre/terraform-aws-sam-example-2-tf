## Introduction

This is the sample project to describe how to initiate & provision a serverless platform on AWS cloud using Terraform & SAM.
The approach is:

- Use Terraform:
  - To initiate & provision all the surrounding infrastructures such as sqs, dynamodb, code pipeline,... and corresponding IAM roles, policies
  - Use AWS Code Pipeline to integrate with Terraform image in docker-hup for CI/CD action.
  - There is a separated github repository for this part.
- Use SAM:
  - To develop, test & debug the source code of lambda function.
  - Build & deploy for API Gateway, Lambda as well as related IAM roles, policies.
  - There is a separated github repository for this part. Can find the SAM repo here [SAM part](https://github.com/duc-hectre/terraform-aws-sam-example-2-sam)

# Sample architecture

This project is to build a simple Todo application which allow user to record their todo action with some simple description likes Todo, Desc & Status.

The AWS structure is:

![Sample Architecture](https://github.com/duc-hectre/duc-hectre/blob/main/TF-SAM-APPROACH-2.png?raw=true)

# Get started.

Regarding to this sample, this is the repository for Terraform part, which contains the definition about SQS, DynamoDB, Code Pipeline for terraform deployment as well as SAM deployment. 

The output such as SQS arn/name, DynamoDb arn/name is populated to SSM Parameter Store to share with SAM part.

```
module "aws_ssm_params" {
  source = "./modules/aws_ssm"

  app_name    = var.resource_tag_name
  environment = var.environment

  parameters = {
    "dynamodb_name" = {
      "type" : "String",
      "value" : aws_dynamodb_table._.name
    },
    "dynamodb_arn" = {
      "type" : "String",
      "value" : aws_dynamodb_table._.arn
    },
    "sqs_queue_name" = {
      "type" : "String",
      "value" : aws_sqs_queue._.name
    },
    "sqs_queue_arn" = {
      "type" : "String",
      "value" : aws_sqs_queue._.arn
    },
  }
}
```

The project structure looks like image below.

![Sample project structure](https://github.com/duc-hectre/duc-hectre/blob/main/tf_2_tf_project_structure.png)

If any changes not regarding to API gateway, Lambda, they will be defined in this terraform parts.

### How to run the project.

Following the steps below to get the project starts.

1. **Install prerequisites**

   - Install AWS CLI tool An AWS account with proper permission with the services we are intend to initiate & use.
   - Install AWS CLI tool Installing or updating the latest version of the AWS CLI - AWS Command Line Interface
   - Configure aws credential.
   - Install Docker - that use to simulate the AWS environment for debugging
   - Install Terraform CLI
   - Install some extensions for VS Code:
     - Terraform
   - Create a CodeStarConnection to establish the connection with SAM repo & Terraform Repo in Github. Then update the corresponding variables value in **terraform.tfvars** file.
   ```
    tf_codestar_connector_credentials  = "code-star-arn-for-terraform-repo"
    sam_codestar_connector_credentials = "code-star-arn-for-sam-repo"
   ```

2. **Deploy**

   As mentioned earlier, we use Terraform as the main method to initiate & define the AWS resources. To deploy whole the application manually, we use Terraform CLI as below:
   First, initiate the terraform library & modules.

   ```
   terraform init
   ```

   Then validate the Terraform configuration.

   ```
   terraform validate
   ```

   Create plan to deploy

   ```
   terraform plan
   ```

   Apply the changes to deploy.

   ```
   terraform apply --auto-approve
   ```

   In this example, we use Terraform to define a AWS Code Pipeline to auto test & deploy the application to AWS cloud. Use can find the definition under main.tf file located in the root folder.

   ```
    module "aws_tf_cicd_pipeline" {
        source = "./modules/aws_tf_cicd_pipeline"

        environment       = var.environment
        region            = var.region
        resource_tag_name = var.resource_tag_name

        cicd_name                      = "tf-cicd-todo"
        codestar_connector_credentials = var.codestar_connector_credentials
        pipeline_artifact_bucket       = "tf-cicd-todo-artifact-bucket"
    }
   ```

   For details of Pipeline definition, refer to the terraform module located in \_./modules/aws_tf_cicd_pipeline

   ![CI/CD pipeline](https://github.com/duc-hectre/duc-hectre/blob/main/tf_1_tf_cicd_pipeline.png)

3. **Destroy**

   To destroy all the AWS resources defined by Terraform, using the CLI below:

   ```
   terraform destroy
   ```
