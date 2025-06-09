policy "ec2-instance-should-not-have-public-ip" {
  source            = "https://registry.terraform.io/v2/policies/hashicorp/FSBP-Policy-Set-for-AWS-Terraform/1.0.2/policy/ec2-instance-should-not-have-public-ip.sentinel?checksum=sha256:14261273828ea26ed043bf97bd7fa4617770d181b0890812014f719f065aeab8"
  enforcement_level = "soft-mandatory"
}

policy "ec2-vpc-flow-logging-enabled" {
  source            = "https://registry.terraform.io/v2/policies/hashicorp/FSBP-Policy-Set-for-AWS-Terraform/1.0.2/policy/ec2-vpc-flow-logging-enabled.sentinel?checksum=sha256:42f2c8ae190e793a0b9fef9ed027faab91e31ac3288cfdb103ec34dffcb22c24"
  enforcement_level = "advisory"
}

module "report" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/FSBP-Policy-Set-for-AWS-Terraform/1.0.2/policy-module/report.sentinel?checksum=sha256:1f414f31c2d6f7e4c3f61b2bc7c25079ea9d5dd985d865c01ce9470152fa696d"
}

module "tfresources" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/FSBP-Policy-Set-for-AWS-Terraform/1.0.2/policy-module/tfresources.sentinel?checksum=sha256:ae40fe0173a1d6203c5c062045432d46beb6397a769d65189d1ec80228ef2161"
}

module "tfplan-functions" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/FSBP-Policy-Set-for-AWS-Terraform/1.0.2/policy-module/tfplan-functions.sentinel?checksum=sha256:e7f04948ec53d7c01ff26829c1ef7079fb072ed5074483f94dd3d00ae5bb67b3"
}

module "tfconfig-functions" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/FSBP-Policy-Set-for-AWS-Terraform/1.0.2/policy-module/tfconfig-functions.sentinel?checksum=sha256:ee1c5baf3c2f6b032ea348ce38f0a93d54b6e5337bade1386fffb185e2599b5b"
}
