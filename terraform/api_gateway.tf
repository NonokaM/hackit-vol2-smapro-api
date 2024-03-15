resource "aws_api_gateway_rest_api" "hackit_smapro_api" {
  name        = "hackit_smapro_api"
  description = "API for retrieving questions based on difficulty"
}

# "/questions" パスのリソース
resource "aws_api_gateway_resource" "questions_resource" {
  rest_api_id = aws_api_gateway_rest_api.hackit_smapro_api.id
  parent_id   = aws_api_gateway_rest_api.hackit_smapro_api.root_resource_id
  path_part   = "questions"
}

# "/questions" パスのメソッド設定
resource "aws_api_gateway_method" "questions_method" {
  rest_api_id   = aws_api_gateway_rest_api.hackit_smapro_api.id
  resource_id   = aws_api_gateway_resource.questions_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# "/questions" パスのLambda統合
resource "aws_api_gateway_integration" "questions_lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.hackit_smapro_api.id
  resource_id             = aws_api_gateway_resource.questions_resource.id
  http_method             = aws_api_gateway_method.questions_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.fetch_questions_function.invoke_arn
}

# API Gatewayのデプロイメント
resource "aws_api_gateway_deployment" "hackit_api_gateway_deployment" {
  depends_on = [aws_api_gateway_integration.questions_lambda_integration]

  rest_api_id = aws_api_gateway_rest_api.hackit_smapro_api.id
  stage_name  = "v1"
  lifecycle {
    create_before_destroy = true
  }
}
