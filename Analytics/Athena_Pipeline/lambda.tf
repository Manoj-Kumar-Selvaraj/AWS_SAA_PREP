# Lambda Function with Environment Variables
resource "aws_lambda_function" "transfer_family_workflow" {
  function_name = "transfer_family_workflow"
  role          = aws_iam_role.secrets_lambda_role.arn
  runtime       = "python3.9"
  filename      = "transfer_family_workflow.zip"
  handler       = "lambda_function.lambda_handler"

  environment {
    variables = {
      PGP_KEY_SECRET        = "AthenaPGPPrivateKey"
      PGP_PASSPHRASE_SECRET = "AthenaPGPPassphrase"
      EMAIL_SENDER          = "ss.mano1998@gmail.com"
      EMAIL_RECIPIENT       = "ss.mano1998@gmail.com"
    }
  }
}