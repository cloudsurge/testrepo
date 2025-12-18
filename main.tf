data "aws_iam_policy_document" "super_expansive" {
  statement {
    effect = "Allow"
    actions = [ "s3:GetObject" ]
    resources = [ "arn:aws:s3:::somebucket/someprefix/*" ]
  }
}