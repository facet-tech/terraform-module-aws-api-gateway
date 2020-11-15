resource "aws_iam_role" "role" {
  name                  = "${var.iam_role_name_prefix}${local.resource_base_name}"
  assume_role_policy    = templatefile("${path.module}/templates/default_iam_role_assume_policy.tpl", {})
  force_detach_policies = var.iam_role_force_detach_policies
  description           = var.iam_role_description
  tags                  = module.default_tags.tags
  lifecycle {
    ignore_changes = [tags["DateCreated"]]
  }
}

resource "aws_iam_role_policy" "policy" {
  name   = local.resource_base_name
  policy = templatefile("${path.module}/templates/default_iam_role_policy.tpl",{})
  role   = aws_iam_role.role.name
}