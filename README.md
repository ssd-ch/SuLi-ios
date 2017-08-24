# SuLi-ios (Shimane University Lecture Information)
## 島根大学の講義情報を表示するiOSアプリ

### 主な機能
* シラバス  
授業名を入力してシラバスを検索し、閲覧することができます。   
ページの一番下に講義場所が表示されるようになっています。
* 教室配当表   
講義場所を表示することができます。  
建物別に絞り込むこともできます。  
* お知らせ  
補講情報を表示することができます。
* 資料アクセス  
workフォルダとMoodleへのアクセスができます。  
workフォルダは島根大学のネットワークに接続していることが条件です。(WiFi,VPNどちらでも可)

### 仕様  
* インストール要件    
推奨バージョン iOS 10 以上

### 開発環境・仕様ライブラリ
* 開発言語 Swift
* 使用外部ライブラリ  
[Kanna](http://tid-kijyun.github.io/Kanna/) (HTMLパーサ)  
[SwiftHTTP](https://github.com/daltoniam/SwiftHTTP) (HTTPクライアント)  
[Realm](https://realm.io/docs/swift/latest/) (データベース)  
[XLPagerTabStrip](https://github.com/xmartlabs/XLPagerTabStrip) (タブビュー)  
[TOSMBClient](https://github.com/TimOliver/TOSMBClient) (SMBクライアント)  

### バグ  
* データの取得がうまくいかないとクラッシュする

### 未実装（実装予定）  
* 時間割管理機能  
* シラバスのブックマーク機能  
