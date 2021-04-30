aws_permissions_sets = {
  readonly = {
    name      = "ReadOnlyAccess"
    policyArn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  },
  poweruser = {
    name      = "PowerUserAccess"
    policyArn = "arn:aws:iam::aws:policy/PowerUserAccess"
  },
  administrator = {
    name      = "AdministratorAccess"
    policyArn = "arn:aws:iam::aws:policy/AdministratorAccess"
  },
  s3reader = {
    name = "S3ReadOnly"
    customPolicy = [
        {
            actions = ["s3:ListAllMyBuckets"]
            resources = ["arn:aws:s3:::*"]
        },
        {
            actions = ["s3:GetObject*"]
            resources = ["arn:aws:s3:::*"]
        }
    ]
  }
}

aws_accounts_permissions = {
  "19987514194" = {
    "admins"       = "administrator"
    "tech_leaders" = "poweruser"
    "developers"   = "readonly"
    "readers"      = "readonly"
  },
  "1191587168432" = {
    "admins"       = "administrator"
    "tech_leaders" = "poweruser"
    "developers"   = "poweruser"
    "readers"      = "readonly"
  }
  "13216842425" = {
    "admins"       = "administrator"
    "tech_leaders" = "readonly"
    "developers"   = "readonly"
    "readers"      = "readonly"
  }
}
