package main

deny contains msg if {
	some change in input.resource_changes
	change.type == "aws_ebs_volume"
	some action in change.change.actions
	action in {"create", "update"}
	not change.change.after.encrypted
	msg := sprintf("%s: EBS volume not encrypted", [change.address])
}
