resource "aws_glue_catalog_database" "athena_pipeline_db" {
  name = "athena_pipeline_db"
}

resource "aws_iam_role" "glue_crawler_role" {
  name = "athena_pipeline_glue_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "glue.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "glue_s3_custom" {
  name        = "glue_s3_access_to_athena_pipeline"
  description = "Allow Glue to access only the Athena pipeline data bucket"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.Athena_Test.arn,
          "${aws_s3_bucket.Athena_Test.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "attach_custom_glue_s3" {
  name       = "attach-custom-s3-policy-to-glue"
  roles      = [aws_iam_role.glue_crawler_role.name]
  policy_arn = aws_iam_policy.glue_s3_custom.arn
}

resource "aws_iam_role_policy_attachment" "glue_s3_full_access" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_crawler" "athena_pipeline_crawler" {
  name          = "athena-pipeline-crawler"
  role          = aws_iam_role.glue_crawler_role.arn
  database_name = aws_glue_catalog_database.athena_pipeline_db.name
  table_prefix  = "pipeline_"
  schedule      = "cron(0/15 * * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.Athena_Test.bucket}/raw/"
  }

  depends_on = [
    aws_iam_policy_attachment.attach_custom_glue_s3,
    aws_iam_role_policy_attachment.glue_s3_full_access
  ]
}
