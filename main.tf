module "label" {
  source     = "git::https://github.com/cloudposse/terraform-null-label.git?ref=tags/0.3.3"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  name       = "${var.name}"
  delimiter  = "${var.delimiter}"
  attributes = "${var.attributes}"
  tags       = "${var.tags}"
}

module "kops_metadata" {
  source       = "git::https://github.com/cloudposse/terraform-aws-kops-data-iam.git?ref=tags/0.1.0"
  cluster_name = "${var.cluster_name}"
}

resource "aws_iam_role" "default" {
  name        = "${module.label.id}"
  description = "Role that can be assumed by external-dns"

  lifecycle {
    create_before_destroy = true
  }

  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    principals {
      type = "AWS"

      identifiers = [
        "${module.kops_metadata.masters_role_arn}",
        "${module.kops_metadata.nodes_role_arn}",
      ]
    }

    effect = "Allow"
  }
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.default.name}"
  policy_arn = "${aws_iam_policy.default.arn}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_policy" "default" {
  name        = "${module.label.id}"
  description = "Grant permissions for external-dns"
  policy      = "${data.aws_iam_policy_document.default.json}"
}

data "aws_route53_zone" "default" {
  count        = "${length(var.dns_zone_names)}"
  name         = "${element(var.dns_zone_names, count.index)}."
  private_zone = false
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "GrantModifyAccessToDomains"

    actions = [
      "route53:ChangeResourceRecordSets",
    ]

    effect = "Allow"

    resources = [
      "${formatlist("arn:aws:route53:::hostedzone/%s", data.aws_route53_zone.default.*.zone_id)}",
    ]
  }

  statement {
    sid = "GrantListAccessToDomains"

    actions = [
      "route53:ListHostedZones",
      "route53:ListResourceRecordSets",
    ]

    effect = "Allow"

    resources = [
      "*",
    ]
  }
}
