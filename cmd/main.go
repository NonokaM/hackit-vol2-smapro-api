package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strconv"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/feature/dynamodb/attributevalue"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb"
	"github.com/aws/aws-sdk-go-v2/service/dynamodb/types"
)

type Question struct {
	ID         int      `json:"id"`
	Difficulty string   `json:"difficulty"`
	TechName   string   `json:"techName"`
	SourceCode string   `json:"sourceCode"`
	Options    []string `json:"options"`
	TechDesc   string   `json:"techDesc"`
	CodeDesc   string   `json:"codeDesc"`
	Result     string   `json:"result"`
	DocLink    string   `json:"docLink"`
}

func handleRequest(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	switch request.Path {
	case "/":
		return events.APIGatewayProxyResponse{
			Body:       "Hello World",
			StatusCode: http.StatusOK,
		}, nil
	case "/questions":
		return getQuestions(ctx, request)
	default:
		return events.APIGatewayProxyResponse{
			Body:       "Not Found",
			StatusCode: http.StatusNotFound,
		}, nil
	}
}

func getQuestions(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// クエリパラメータからIDを取得する
	idStr := request.QueryStringParameters["id"]

	id, err := strconv.Atoi(idStr)
	if err != nil {
		return serverError(err)
	}

	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return serverError(err)
	}

	svc := dynamodb.NewFromConfig(cfg)

	// DynamoDBの項目を取得
    result, err := svc.GetItem(ctx, &dynamodb.GetItemInput{
        TableName: aws.String("hackit_questions_table"),
        Key: map[string]types.AttributeValue{
            "id": &types.AttributeValueMemberN{Value: strconv.Itoa(id)},
        },
    })
	if err != nil {
		return serverError(err)
	}

	var question Question
	err = attributevalue.UnmarshalMap(result.Item, &question)
	if err != nil {
		return serverError(err)
	}

	questionJSON, err := json.Marshal(question)
	if err != nil {
		return serverError(err)
	}

	return events.APIGatewayProxyResponse{
		Body:       string(questionJSON),
		StatusCode: http.StatusOK,
	}, nil
}

func serverError(err error) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusInternalServerError,
		Body:       fmt.Sprintf("Internal Server Error: %v", err),
	}, nil
}

// func handler(ctx context.Context, event events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
// 	response := events.APIGatewayProxyResponse{
// 		StatusCode: 200,
// 		Body:       "\"Hello from Lambda!\"",
// 	}
// 	return response, nil
// }

func main() {
	lambda.Start(handleRequest)
}
