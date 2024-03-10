resource "aws_api_gateway_rest_api" "hackit_smapro_api" {
  name        = "hackit_smapro_api"
  description = "API for retrieving questions based on difficulty"
}

resource "aws_api_gateway_resource" "questions_resource" {
  rest_api_id = aws_api_gateway_rest_api.hackit_smapro_api.id
  parent_id   = aws_api_gateway_rest_api.hackit_smapro_api.root_resource_id
  path_part   = "questions"
}

resource "aws_api_gateway_method" "hackit_api_gateway_method" {
  rest_api_id   = aws_api_gateway_rest_api.hackit_smapro_api.id
  resource_id   = aws_api_gateway_resource.questions_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.hackit_smapro_api.id
  resource_id = aws_api_gateway_resource.questions_resource.id
  http_method = aws_api_gateway_method.hackit_api_gateway_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fetch_questions_function.invoke_arn
}

# resource "aws_api_gateway_stage" "hackit_api_gateway_stage" {
#   depends_on = [aws_api_gateway_deployment.hackit_api_gateway_deployment]

#   deployment_id = aws_api_gateway_deployment.hackit_api_gateway_deployment.id
#   rest_api_id   = aws_api_gateway_rest_api.hackit_smapro_api.id
#   stage_name    = "v1"
# }

resource "aws_api_gateway_deployment" "hackit_api_gateway_deployment" {
  depends_on = [aws_api_gateway_integration.lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.hackit_smapro_api.id
  stage_name = "v1"
  lifecycle {
    create_before_destroy = true
  }
}
