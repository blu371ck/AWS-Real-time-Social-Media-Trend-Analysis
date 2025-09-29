resource "aws_iam_role" "flink_role" {
  name = "flink-execution-role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = {
          Service = "kinesisanalytics.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "flink_s3" {
  role       = aws_iam_role.flink_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "flink_msk" {
  role       = aws_iam_role.flink_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonMSKReadOnlyAccess"
}