resource "aws_lambda_function" "fetch_questions_function" {
  function_name = "fetch_questions_function"
  role          = aws_iam_role.hackit_lambda_role.arn

  // Lambda関数のDockerイメージをECRから参照
  image_uri = "${aws_ecr_repository.hackit_ecr_repository.repository_url}:latest"

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

resource "aws_lambda_permission" "hackit_api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_questions_function.function_name
  principal     = "apigateway.amazonaws.com"

  // API GatewayのARN
  source_arn = "${aws_api_gateway_rest_api.hackit_smapro_api.execution_arn}/*/GET/questions"
}
