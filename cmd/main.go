package main

import (
	"context"
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"strconv"
	"time"

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
	difficulty := request.QueryStringParameters["difficulty"]
	if difficulty == "" {
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusBadRequest,
			Body:       "Bad Request: Missing difficulty parameter",
		}, nil
	}

	limitStr := request.QueryStringParameters["limit"]
	if limitStr == "" {
		limitStr = "3" // デフォルト値
	}

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit <= 0 {
		return events.APIGatewayProxyResponse{
			StatusCode: http.StatusBadRequest,
			Body:       "Bad Request: Invalid number of questions",
		}, nil
	}

	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		return serverError(err)
	}

	svc := dynamodb.NewFromConfig(cfg)

	// IDのみを取得
	queryInput := &dynamodb.QueryInput{
		TableName:              aws.String("hackit_questions_table"),
		IndexName:              aws.String("difficulty-index"),
		KeyConditionExpression: aws.String("difficulty = :difficulty"),
		ProjectionExpression:   aws.String("id"),
		ExpressionAttributeValues: map[string]types.AttributeValue{
			":difficulty": &types.AttributeValueMemberS{Value: difficulty},
		},
	}

	result, err := svc.Query(ctx, queryInput)
	if err != nil {
		return serverError(err)
	}

	var questionIDs []int
	for _, item := range result.Items {
		var q Question
		err = attributevalue.UnmarshalMap(item, &q)
		if err != nil {
			return serverError(err)
		}
		questionIDs = append(questionIDs, q.ID)
	}

	// ランダムにIDを選択
	selectedIDs := selectRandomIDs(questionIDs, limit)

	// 選択されたIDに基づいて完全な問題データを取得
	var selectedQuestions []Question
	for _, id := range selectedIDs {
		getItemInput := &dynamodb.GetItemInput{
			TableName: aws.String("hackit_questions_table"),
			Key: map[string]types.AttributeValue{
				"id": &types.AttributeValueMemberN{Value: strconv.Itoa(id)},
			},
		}
		result, err := svc.GetItem(ctx, getItemInput)
		if err != nil {
			return serverError(err)
		}

		var question Question
		err = attributevalue.UnmarshalMap(result.Item, &question)
		if err != nil {
			return serverError(err)
		}

		selectedQuestions = append(selectedQuestions, question)
	}

	questionsJSON, err := json.Marshal(selectedQuestions)
	if err != nil {
		return serverError(err)
	}

	return events.APIGatewayProxyResponse{
		Body:       string(questionsJSON),
		StatusCode: http.StatusOK,
	}, nil
}

func selectRandomIDs(ids []int, count int) []int {
	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(ids), func(i, j int) { ids[i], ids[j] = ids[j], ids[i] })

	if len(ids) < count {
		count = len(ids)
	}

	return ids[:count]
}

func serverError(err error) (events.APIGatewayProxyResponse, error) {
	return events.APIGatewayProxyResponse{
		StatusCode: http.StatusInternalServerError,
		Body:       fmt.Sprintf("Internal Server Error: %v", err),
	}, nil
}

func main() {
	lambda.Start(handleRequest)
}
