resource "aws_iam_role_policy_attachment" "this" {
  for_each   = var.attachments
  role       = var.role
  policy_arn = each.value
}
