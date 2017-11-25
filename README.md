# askme

sarahah.comのクローンをreactjsを使って作成する勉強のためのサービス。

## 機能

- ユーザー登録
  - twitter認証
- 登録済ユーザー機能
  - プロフィール変更
  - 質問一覧
    - 質問の削除
    - 質問のシェア
- 未登録ユーザー機能
  - 質問投稿

## 構成

- サーバーサイド(web,api)
  - sinatra
- フロントエンド
  - reactjs
- ネイティブアプリ(ios,android)
  - react-native

## サーバーサイド

### サーバー起動

```
bundle exec ruby app/app.rb
```

### テスト

```
bundle exec rspec app/spec
```
