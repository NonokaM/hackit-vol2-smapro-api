# hackit-vol2-smapro-api
ハッカソンで使用するサーバレスAPI
フロントエンドリポジトリ: <https://github.com/Mayu0628/hackit-vol2-smapro>


# API概要
このAPIは、特定のプログラミング関連の問題を取得するために使用されます。
以下は、APIの主なエンドポイントとその使い方についての説明です。

## エンドポイント

### 問題の取得

- Path: /questions
- Method: GET
- 説明: 指定された難易度に基づいて問題を取得
- クエリパラメータ:
- difficulty: 問題の難易度を指定します（例: easy, medium, hard）。
- limit: 取得する問題数を指定します（任意、指定しなかった場合デフォルトで3件取得）。


#### リクエスト例

```plaintext
GET /questions?difficulty=easy&limit=5
```

このリクエストは、難易度が「easy」で、5つの問題を取得します。


### レスポンス形式

APIのレスポンスはJSON形式で提供されます。
以下は、問題の取得リクエストに対するレスポンスの例です。

```json
[
{
"id": 1,
"difficulty": "easy",
"techName": "技術名",
"sourceCode": "print('hello')",
"options": ["選択肢1", "選択肢2", "選択肢3", "選択肢4", "選択肢5"],
"techDesc": "技術の解説",
"codeDesc": "コードについての説明",
"result": "実行結果",
"docLink": "https://example.com/"
},
{
// 他の問題...
}
]
```
