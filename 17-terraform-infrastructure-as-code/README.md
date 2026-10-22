# Terraform Infrastructure as Code Fundamentals

I used Terraform to describe and manage a small AWS S3 environment. The
configuration is split into focused files for the Terraform and provider
requirements, input variables, resources, and outputs. The bucket is private,
encrypted, versioned, tagged, and protected by an S3 public-access block.

## Architecture

```text
Terraform configuration
        |
        v
Terraform CLI -----> AWS provider -----> AWS API
        |                                  |
        v                                  v
terraform.tfstate                    Private S3 bucket
                              + encryption and versioning
```

Terraform is declarative: the configuration describes the desired result.
Terraform compares configuration, state, and the real infrastructure before
it proposes an execution plan.

## Project structure

```text
17-terraform-infrastructure-as-code/
├── versions.tf                 Terraform and provider constraints
├── providers.tf                AWS provider configuration
├── variables.tf                Typed and validated inputs
├── main.tf                     S3 resources and security controls
├── outputs.tf                  Useful values after apply
├── terraform.tfvars.example    Safe example input values
├── tests/security.tftest.hcl   Offline security-control assertions
├── Makefile                    Repeatable Terraform commands
└── .gitignore                  State, plans, credentials, and caches
```

## Prerequisites and authentication

```bash
terraform version
aws --version
aws sts get-caller-identity
```

AWS credentials are supplied by the AWS CLI credential chain. Access keys are
never written in Terraform files or committed to Git.

Create the local variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars` is ignored because real variable files may contain
environment-specific or sensitive values.

## Task 1: Initialize, format, validate, and plan

```bash
terraform init
terraform fmt -check -recursive
terraform validate
terraform test
terraform plan -out=tfplan
terraform show -no-color tfplan
```

`init` downloads the locked AWS provider, `validate` checks the configuration,
and the mock-provider test verifies the security controls without creating
cloud resources. `plan` previews the real AWS changes. A saved plan makes the
reviewed operations explicit and repeatable.

<!-- Evidence 01 will be added after the verified init and plan. -->

## Task 2: Apply and inspect outputs and state

```bash
terraform apply tfplan
terraform output
terraform state list
terraform state show aws_s3_bucket.lab
```

State maps Terraform resource addresses to real AWS resource IDs. The state
file is required locally but is excluded from Git because it can contain
sensitive infrastructure data.

Verify the bucket through the AWS API:

```bash
BUCKET=$(terraform output -raw bucket_name)
aws s3api head-bucket --bucket "$BUCKET"
aws s3api get-public-access-block --bucket "$BUCKET"
aws s3api get-bucket-encryption --bucket "$BUCKET"
aws s3api get-bucket-versioning --bucket "$BUCKET"
```

<!-- Evidence 02 will be added after the verified apply and state inspection. -->

## Task 3: Demonstrate an in-place configuration change

Change `environment = "dev"` to `environment = "test"` in the ignored local
`terraform.tfvars`, then run:

```bash
terraform plan
```

Terraform should propose tag changes with `~ update in-place`, rather than
recreating the bucket. After reviewing the plan:

```bash
terraform apply
```

<!-- Evidence 03 will be added after the verified update plan and apply. -->

## Task 4: Preview and perform safe cleanup

Destroy is a real deletion operation. I preview the destroy plan before
approving it:

```bash
terraform plan -destroy
terraform destroy
terraform state list
```

An empty `terraform state list` after destroy confirms that no resources from
this configuration remain managed.

<!-- Evidence 04 will be added after the verified destroy. -->

## Security controls

- All forms of S3 public access are blocked.
- S3-managed AES-256 encryption is configured explicitly.
- Bucket versioning is enabled.
- Object ownership is enforced by the bucket owner; ACLs are disabled.
- Incomplete multipart uploads are removed after seven days.
- Provider versions are constrained and recorded in the dependency lock file.
- State, plans, `.terraform`, variable files, and credentials are ignored.
- The bucket uses a generated suffix to avoid globally unique name conflicts.

## What I understood

- A provider translates Terraform resource operations into cloud API calls.
- Variables make one configuration reusable across environments.
- Resources represent infrastructure objects and their desired settings.
- Outputs expose useful values to people, scripts, and later automation.
- `terraform plan` is a preview; `terraform apply` performs the approved plan.
- Terraform state links resource addresses in code to real infrastructure.
- Infrastructure changes should be reviewed in a plan before apply or destroy.
- State and credentials must never be committed to a public repository.

## References

- [Terraform CLI workflow](https://developer.hashicorp.com/terraform/intro/core-workflow)
- [Terraform language](https://developer.hashicorp.com/terraform/language)
- [AWS provider authentication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration)
- [Terraform state](https://developer.hashicorp.com/terraform/language/state)
- [AWS S3 security best practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
