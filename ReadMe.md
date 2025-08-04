# Terrafrom Infrastructure

This repository manages AWS Cloud Infrastructure using Terraform.

## Initial Setup

After installing Terraform, follow these steps to set up the environment and apply the VPC module first:

1. Initialize the Terraform working directory:
    ```sh
    terraform init
    ```
2. Switch to the desired workspace (create it if it doesn't exist):
    ```sh
    terraform workspace select -or-create $workspace_name
    ```
3. Apply the VPC module to ensure subnet IDs are available to other modules:
    ```sh
    terraform plan -var-file="terraform.tfvars" -out="terraform.tfplan" -target="module.vpc"
    terraform apply "terraform.tfplan"
    ```

## Making Changes to Existing Infrastructure

Follow these steps to modify or update the infrastructure:

1. List available workspaces to ensure you're in the correct environment:
    ```sh
    terraform workspace list
    ```
2. Switch to the desired workspace (create it if it doesn't exist):
    ```sh
    terraform workspace select -or-create $workspace_name
    ```
3. Review the current state and create a plan to preview changes:
    ```sh
    terraform plan -var-file="terraform.tfvars" -out="terraform.tfplan"
    ```
4. Apply the proposed changes:
    ```sh
    terraform apply "terraform.tfplan"
    ```

## TODOs:

- Use Karpenter instead of/along with SPOT nodes, it should probably optimize aws costs better.
- Complete TODOs written in the code.

## Tips:

- Review plans carefully before applying changes to avoid unintended modifications.
- Ensure you are in the correct workspace to prevent altering the wrong environment.
- Version control your Terraform configurations to track changes and facilitate collaboration.
