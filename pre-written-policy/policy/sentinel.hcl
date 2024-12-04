policy "vpc-flow-logging-enabled" {
  source            = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-VPC-Terraform/1.0.1/policy/vpc-flow-logging-enabled.sentinel?checksum=sha256:179e54896ab33a8891a1eaeec6f5e02fb3463ef4b5d96a95bbf10cfa1a77e455"
  enforcement_level = "advisory"
}

module "report" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-VPC-Terraform/1.0.1/policy-module/report.sentinel?checksum=sha256:e8422be2bf132524ef264934609cbfbf4846e77936003448a69747330fcfe9ba"
}

module "tfresources" {
  source = "https://registry.terraform.io/v2/policies/hashicorp/CIS-Policy-Set-for-AWS-VPC-Terraform/1.0.1/policy-module/tfresources.sentinel?checksum=sha256:54edaac2a209f55d117f92291baae78d400fd47d94336e614f2cadf6b38bea99"
}
