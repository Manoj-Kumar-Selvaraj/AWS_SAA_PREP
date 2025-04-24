# ACM Certificate with DNS Validation
resource "aws_acm_certificate" "Athena_Pipeline_server_cert" {
  domain_name       = "athena.manoj-techworks.site"
  validation_method = "DNS"
  key_algorithm     = "RSA_4096"

  tags = {
    Name = "Athena_Pipeline_server_cert"
  }
}

# Route53 Hosted Zone (Private)
resource "aws_route53_zone" "Athena_Pipeline_Zone" {
  name = "athena.manoj-techworks.site"

  vpc {
    vpc_id = aws_vpc.Transfer_Fam_VPC.id
  }

  tags = {
    Name = "Athena_Private_Zone"
  }
}

# Route53 Record for ACM DNS Validation
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.Athena_Pipeline_server_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = aws_route53_zone.Athena_Pipeline_Zone.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 300
  records = [each.value.record]
}

# Wait for certificate validation
resource "aws_acm_certificate_validation" "cert" {
  certificate_arn         = aws_acm_certificate.Athena_Pipeline_server_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}


# Transfer Family Workflow Terraform Configuration

# IAM Role for Transfer to invoke Lambda
resource "aws_iam_role" "transfer_workflow_role" {
  name = "TransferWorkflowRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "transfer.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy to allow Lambda invocation
resource "aws_iam_role_policy" "transfer_workflow_lambda_invoke" {
  name = "InvokeLambdaPolicy"
  role = aws_iam_role.transfer_workflow_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "lambda:InvokeFunction"
        ],
        Resource = aws_lambda_function.decrypt_csv_lambda.arn
      }
    ]
  })
}

# Transfer Workflow that triggers Lambda
resource "aws_transfer_workflow" "aws_transfer_workflow" {
  description = "Workflow to decrypt and validate CSV via Lambda"

  steps {
    type = "CUSTOM"

    custom_step_details {
      name            = "DecryptValidateCSV"
      target          = aws_lambda_function.transfer_family_workflow.arn
      timeout_seconds = 90
    }
  }

  tags = {
    Name = "Athena_Decrypt_Validate_Workflow"
  }
}

# AWS Transfer Family Server
resource "aws_transfer_server" "Athena_Pipeline_server" {
  depends_on = [aws_acm_certificate_validation.cert]

  identity_provider_type = "SERVICE_MANAGED"
  endpoint_type          = "VPC"
  protocols              = ["SFTP", "FTPS"]
  certificate            = aws_acm_certificate.Athena_Pipeline_server_cert.arn
  domain                 = "S3"

  endpoint_details {
    vpc_id             = aws_vpc.Transfer_Fam_VPC.id
    subnet_ids         = [aws_subnet.Transfer_Fam_Public.id]
    security_group_ids = [aws_security_group.transfer_family_sg.id]
  }

  workflow_details {
    on_upload {
      workflow_id    = aws_transfer_workflow.aws_transfer_workflow.id
      execution_role = aws_iam_role.transfer_workflow_role.arn
    }
  }

  tags = {
    Name = "Athena_Pipeline_server"
  }
}

