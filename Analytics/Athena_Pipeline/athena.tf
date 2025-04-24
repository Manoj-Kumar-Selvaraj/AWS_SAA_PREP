# Step 1: Create Athena Workgroup (optional but recommended)

resource "aws_athena_workgroup" "athena_pipeline_wg" {
  name = "athena-pipeline-wg"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.Athena_Test.bucket}/athena-results/"
    }

    enforce_workgroup_configuration = true
  }
}

# Step 2: Write Terraform Athena Query (Optional in Code)

resource "aws_athena_named_query" "select_all_query" {
  name        = "GetAllData"
  database    = aws_glue_catalog_database.athena_pipeline_db.name
  query       = "SELECT * FROM pipeline_sales_data;"
  description = "Query to get all data from pipeline_sales_data table"
  workgroup   = aws_athena_workgroup.athena_pipeline_wg.name
}


