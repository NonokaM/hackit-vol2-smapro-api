resource "aws_lambda_function" "fetch_questions_function" {
  function_name = "fetch_questions_function"
  role          = aws_iam_role.example_lambda_role.arn

  // Lambda関数のDockerイメージをECRから参照
  image_uri = aws_ecr_repository.example_repository.repository_url

  package_type = "Image"
}

// Lambda関数のためのIAMロール
resource "aws_iam_role" "hackit_lambda_role" {
  name = "hackit_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
      },
    ],
  })
}
