resource "aws_lambda_function" "fetch_questions_function" {
  function_name = "fetch_questions_function"
  role          = aws_iam_role.hackit_lambda_role.arn

  // Lambda関数のDockerイメージをECRから参照
  image_uri = "your_ecr_repository_uri"

  package_type = "Image"
}

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

resource "aws_iam_policy" "lambda_api_dynamo_policy" {
  name        = "lambda_api_dynamo_policy"
  description = "A policy that allows lambda to access DynamoDB."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "lambda_api_dynamo_attachment" {
  role       = aws_iam_role.hackit_lambda_role.name
  policy_arn = aws_iam_policy.lambda_api_dynamo_policy.arn
}

resource "aws_lambda_permission" "hackit_api_gateway_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_questions_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.hackit_smapro_api.execution_arn}/*/*"
}
