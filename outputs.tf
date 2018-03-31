output "role_name" {
  value = "${aws_iam_role.default.name}"
}

output "role_unique_id" {
  value = "${aws_iam_role.default.unique_id}"
}

output "role_arn" {
  value = "${aws_iam_role.default.arn}"
}

output "policy_name" {
  value = "${aws_iam_policy.default.name}"
}

output "policy_id" {
  value = "${aws_iam_policy.default.id}"
}

output "policy_arn" {
  value = "${aws_iam_policy.default.arn}"
}
