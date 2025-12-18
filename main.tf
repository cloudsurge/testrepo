data "aws_iam_policy_document" "super_expansive" {
  statement {
    effect = "Allow"
    actions = [ "*" ]
    resources = [ "*" ]
  }
}