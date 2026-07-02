package main

required_tags := {"Environment", "Owner"}

taggable_types := {"aws_vpc", "aws_security_group", "aws_ebs_volume", "aws_instance"}

deny contains msg if {
	some change in input.resource_changes
	taggable_types[change.type]
	change.change.actions[_] == "create"
	tags := object.get(change.change.after, "tags", {})
	missing := required_tags - {k | some k, _ in tags}
	count(missing) > 0
	msg := sprintf("%s %s: required tags missing: %v", [change.type, change.address, missing])
}
