package main

deny contains msg if {
	some change in input.resource_changes
	change.type == "aws_security_group"
	change.change.actions[_] == "create"
	some ingress in change.change.after.ingress
	some cidr in ingress.cidr_blocks
	cidr == "0.0.0.0/0"
	msg := sprintf("%s: ingress open to 0.0.0.0/0 (port %d)", [change.address, ingress.from_port])
}
