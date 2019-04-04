//
//  NoticeViewContoller.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/12.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import RealmSwift
import GoogleMobileAds
import DZNEmptyDataSet

class NoticeViewContoller : UIViewController, UITableViewDataSource, UITableViewDelegate, GADBannerViewDelegate {
    
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    @IBOutlet weak var bannerViewHeightConstraint: NSLayoutConstraint!
    
    //CancelInfoオブジェクト
    var cancelInfo : Results<CancelInfo>!
    
    //Realmの通知用のトークン
    var token : NotificationToken!
    
    //セルの種類(true:DetailCell false:Cell)
    var cellType = [[Bool]]()
    
    //セクション
    var sectionIndex: [(String, Int)] = []
    
    //UserDefaults
    let userDefault = UserDefaults.standard
    
    //リロードボタンが押された時の処理
    @IBAction func pushReloadButton(_ sender: UIBarButtonItem) {
        //ボタンを無効化
        self.reloadButton.isEnabled = false
        
        //プログレスバーを表示、0.1にセット
        self.progressView.setProgress(0.1, animated: false)
        self.progressView.isHidden = false
        
        GetCancelInfo.start(
            completeHandler: {
                DispatchQueue.main.async {
                    //ボタンを有効化
                    self.reloadButton.isEnabled = true
                    self.progressView.setProgress(1.0, animated: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.progressView.isHidden = true
                }
        },
            errorHandler: { message in
                DispatchQueue.main.async {
                    //ボタンを有効化
                    self.reloadButton.isEnabled = true
                    
                    self.progressView.isHidden = true
                    //アラートを作成
                    let alert = MyAlertController.action(title: NSLocalizedString("alert-error-title", comment: "エラーアラートのタイトル"), message: message)
                    //アラートを表示
                    self.present(alert, animated: true, completion: nil)
                }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.cancelInfo  = try! Realm().objects(CancelInfo.self).sorted(byKeyPath: "id")
        
        self.setSectionIndexCellType()
        
        self.token = self.cancelInfo.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial(_):
                break
            case .update(_, _, _, _):
                self.setSectionIndexCellType()
                self.tableView.reloadData()
                break
            case .error:
                break
            }
        }
        
        //ナビゲーションバーの半透過処理により色がおかしくなるのでオフにする
        self.navigationController?.navigationBar.isTranslucent = false
        
        //テーブルビューデリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        //空白行のセパレーターを非表示にする
        self.tableView.tableFooterView = UIView(frame: .zero)
        
        self.progressView.isHidden = true
        
        //バナー広告
        self.bannerView.adUnitID = NSLocalizedString("banner-id", tableName: "ResourceAddress", comment: "バナーID")
        self.bannerView.rootViewController = self
        self.bannerView.delegate = self
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "17a73169a9326a325c38836f01f7624c"]
        self.bannerView.load(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("NoticeViewContoller : load display")
        
        let now = Date()
        
        // デフォルト値登録※すでに値が更新されていた場合は、更新後の値のままになる
        self.userDefault.register(defaults: [UserDefaultsKey.noticeUpdateInterval: 0.0])
        let interval = now.timeIntervalSince1970 - self.userDefault.double(forKey: UserDefaultsKey.noticeUpdateInterval)
        print("notice update interval : \(interval)")
        
        //1日以上データを更新してない場合はデータを取得する
        if interval >= 86400.0 && self.userDefault.bool(forKey: UserDefaultsKey.dataSync) {
            self.pushReloadButton(self.reloadButton)
            self.userDefault.set(now.timeIntervalSince1970, forKey: UserDefaultsKey.noticeUpdateInterval)
        }
        
        //バナー広告
        if self.userDefault.bool(forKey: UserDefaultsKey.adsDisplay) {
            self.bannerView.isAutoloadEnabled = true
            self.bannerViewHeightConstraint.constant = 50
            self.bannerView.isHidden = false
        }
        else {
            self.bannerView.isAutoloadEnabled = false
            self.bannerViewHeightConstraint.constant = 0
            self.bannerView.isHidden = true
        }
        
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        if self.userDefault.bool(forKey: UserDefaultsKey.adsDisplay) {
            self.bannerViewHeightConstraint.constant = 50
            self.bannerView.isHidden = false
        }
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("NoticeViewContoller : \(error.localizedDescription)")
        self.bannerViewHeightConstraint.constant = 0
        self.bannerView.isHidden = true
    }
    
    // セルの内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.cellType[indexPath.section][indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! NoticeCustomViewDetailCell
            cell.titleLabel?.text = self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].classname + " (" + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].department + ")"
            cell.subtitleLabel?.text = self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].person
            cell.classificationLabel?.text = NSLocalizedString("lectureNotice-item-classification", comment: "講義案内:分類") + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].classification
            cell.timeLabel?.text = NSLocalizedString("lectureNotice-item-time", comment: "講義案内:時限") + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].time
            cell.placeLabel?.text = NSLocalizedString("lectureNotice-item-place", comment: "講義案内:教室") + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].place
            cell.noteLabel?.text = NSLocalizedString("lectureNotice-item-note", comment: "講義案内:備考") + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].note
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].classname + " (" + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].department + ")"
            cell.detailTextLabel?.text = self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].person
            return cell
        }
    }
    
    //セクション名を返す
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        return self.sectionIndex[section].0
    }
    
    //各セクションのデータの個数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sectionIndex[section].1
    }
    
    //セクションの個数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionIndex.count
    }
    
    //セルが選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //選択されたセルの状態を切り替える
        if self.cellType[indexPath.section][indexPath.row] {
            self.cellType[indexPath.section][indexPath.row] = false
        }
        else {
            self.cellType[indexPath.section][indexPath.row] = true
        }
        //テーブルを更新
        self.tableView.reloadData()
    }
    
    //セルの高さを返す
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var identifier = ""
        if self.cellType[indexPath.section][indexPath.row] {
            identifier = "DetailCell"
        }
        else {
            identifier = "Cell"
        }
        return self.tableView.dequeueReusableCell(withIdentifier: identifier)!.bounds.size.height
    }
    
    //セクションとセルタイプを設定する
    func setSectionIndexCellType() {
        
        var array: [(String, Int)] = []
        var tmp = ""
        for data in self.cancelInfo {
            if tmp != data.date {
                array.append((data.date, 1))
                tmp = data.date
            }
            else {
                let index = array.count - 1
                array[index] = (array[index].0, array[index].1 + 1)
            }
        }
        self.sectionIndex = array
        
        //セルの状態を初期化
        self.cellType = []
        
        for i in 0..<self.sectionIndex.count {
            self.cellType.append([Bool]())
            for _ in 0..<self.sectionIndex[i].1 {
                self.cellType[i].append(false)
            }
        }
    }
    
}

extension NoticeViewContoller: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("lectureNotice-noItem", comment: "講義案内:データなし"), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
    }
}
