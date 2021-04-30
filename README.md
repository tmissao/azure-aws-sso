# SSO AzureAD e AWS

This project intends to provision the Single Sign On functionality for AzureAd users on AWS accounts.

## Setup
---
To execute this project it is necessary configuring the following items:

- AWS Organizations Account
- Azure Account
- [AWS SSO application between AzureAD and AWS](./artifact/setup-sso-azure-aws.gif)
- [Automatic Users/Groups Provisioning between AzureAD and AWS ](setup-automatic-user-provisioning.gif)
- [Create a Terraform Application on Azure](./artifact/terraform-azure-setup.gif)
- [Install TF_ENV](https://github.com/tfutils/tfenv)

## How it Works
---
* ### Adding an User
To add a new user it is necessary to edit the [vars-users.auto.tfvars](./src/vars-users.auto.tfvars) file, adding a new entry in the user **users** dictionary. The new entry must be in accordance with the following template:
```javascript
/*
  "username" = {
    "firstName" = "Name"
    "lastName" = "Surname"
    "role" = "developers" // Role in the company, this value must be one of the role_groups` dictionary keys. Defined in the vars-groups.auto. file
    "squad" = "time1"     // Optional variable, meaning that the user is part of a squad. This value must be one of the squad_groups` dictionary keys. Defined in the vars-groups.auto.tfvars file
  }
*/
"tiago.missao" = {
    "firstName" = "Tiago"
    "lastName" = "Missão"
    "role" = "admin"
    "squad" = "time1"
  }
```

* ### Adding an AWS Account
To add a new AWS account it is necessary to edit the [vars-aws-accounts.auto.tfvars](./src/vars-aws-accounts.auto.tfvars), adding a new entry in the **aws_accounts_permissions** dictionary. The new entry must be in accordance with the following template:
```javascript
/*
  "AWS_ACCOUNT_ID" = {
    "role" = "aws_permission" // Role in the company, this value must be one of the role_groups` dictionary keys. Defined in the vars-groups.auto.tfvars file, followed by the AWS` policy associated to the role.
                              // Also, The "aws_permission" value must be one of the aws_permissions_sets` keys defined ing the vars-aws-accounts.auto.tfvars file
  }
*/
"887526423960" = {
    "admin" = "administrator"
    "tech_leaders" = "poweruser"
    "developers" = "readonly"
    "readers" = "readonly"
  }
```

* ### Adding a new Role Group
To add a new role group it is necessary to edit the [vars-groups.auto.tfvars](./src/vars-groups.auto.tfvars) file, adding a new entry in the **role_groups** dictionary. The new entry must be in accordance with the following template:
```javascript
/*
  "Group`s Identifier" = {
    "name" = "Group`s name" (Display Name)
  },
*/
  "admin" = {
    "name" = "Admins"
  },
```

* ### Adding a new Squad Group
To add a new squad group it is necessary to edit the [vars-groups.auto.tfvars](./src/vars-groups.auto.tfvars) file, adding a new entry in the **squad_groups** dictionary. The new entry must be in accordance with the following template:
```javascript
/*
  "Group`s Identifier" = {
    "name" = "Group`s name" (Display Name)
  },
*/
  "time1" = {
    "name" = "Time Devops"
  },
```

## Execution
---

This project is executed by [Terraform](https://www.terraform.io/) tool. And can be archieved by performing the following steps:
```bash
tfenv install   # Install the correct Terraform`s version used by the project. The Terraform`s version is defined in the [.terraform-version](./src/.terraform-version) file
tfenv use       # Configures the runtime to use the correct terraform`s version
terraform plan  # Creates an execution plan, showing all the modifications that will be applied
terraform apply # Applies all the modifications
```

## Attention
---
The execution time should takes at least **40 minutes** since the syncronization process between AzureAD and AWS occurs in a 40 minutes interval.

## Results
---
![](./artifact/test-user-sso-azure-aws.gif)
## References
---
- [Documentação Microsoft](https://docs.microsoft.com/en-us/azure/active-directory/saas-apps/aws-single-sign-on-tutorial)
- [Vídeo Tutorial](https://www.youtube.com/watch?v=VIJtaGf24bA)


