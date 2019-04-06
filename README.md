# SuLi-iOS (Shimane University Lecture Information)
## 島根大学の講義情報を表示するiOSアプリ

### Webサイト
#### [https://suli.ssdtic.net](https://suli.ssdtic.net)

### 主な機能
* シラバス  
授業名を入力してシラバスを検索し、閲覧することができます。   
ページの一番下に講義場所が表示されるようになっています。
* 教室配当表   
講義場所を表示することができます。  
建物別に絞り込むこともできます。  
* 講義情報  
補講情報を表示することができます。
* 資料・リンク  
Workフォルダへのアクセスができます。  
Workフォルダは島根大学のネットワークに接続していることが条件です。(WiFi,VPNどちらでも可)
島根大学に関する各種Webサイトにアクセスできます。

### 仕様  
* インストール要件    
推奨バージョン iOS 9.0 以上 (動作確認済み)

### 開発環境・使用ライブラリ
* 開発言語 Swift
* 開発環境 Xcode
* 使用ライブラリ  
[DZNEmptyDataSet](https://github.com/dzenbot/DZNEmptyDataSet) (テーブルビュー)  
[Kanna](http://tid-kijyun.github.io/Kanna/) (HTMLパーサ)  
[Alamofire](https://github.com/Alamofire/Alamofire) (HTTPクライアント)  
[Realm](https://realm.io/docs/swift/latest/) (データベース)  
[XLPagerTabStrip](https://github.com/xmartlabs/XLPagerTabStrip) (タブビュー)  
[TOSMBClient](https://github.com/TimOliver/TOSMBClient) (SMBクライアント)  
使用ライブラリの謝辞は[こちら](https://github.com/ssd-ch/SuLi-ios/blob/master/Acknowledgements.md)

### バグ  
* データ同期処理をあるタイミングで複数回キャンセルするとクラッシュする？

### 未実装（実装予定）  
* 時間割管理機能  
* シラバスのブックマーク機能  

### ライセンス
© 2017 Taichi Shishido

特定のライセンスには基づきませんが以下の事項に従ってください。
* 接続先のサーバー(島根大学)等に負荷をかける行為を禁止
* 商用利用を禁止
* ソースコードまたはビルドデータの二次配布を禁止
