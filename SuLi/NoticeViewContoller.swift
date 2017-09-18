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

class NoticeViewContoller : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    //CancelInfoオブジェクト
    let cancelInfo = try! Realm().objects(CancelInfo.self).sorted(byKeyPath: "id")
    
    //セルの種類(true:DetailCell false:Cell)
    var cellType = [[Bool]]()
    
    //セクション
    var sectionIndex: [(String, Int)] = []
    
    //リロードボタンが押された時の処理
    @IBAction func pushReloadButton(_ sender: Any) {
        //タッチアクションを無効化
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        //プログレスバーを表示、0.1にセット
        self.progressView.setProgress(0.1, animated: false)
        self.progressView.isHidden = false
        
        GetCancelInfo.start(
            completeHandler: {
                DispatchQueue.main.async {
                    self.setSectionIndexCellType()
                    self.tableView.reloadData()
                    //タッチアクションを有効化
                    UIApplication.shared.endIgnoringInteractionEvents()
                    self.progressView.setProgress(1.0, animated: true)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    self.progressView.isHidden = true
                }
        },
            errorHandler: { message in
                DispatchQueue.main.async {
                    //タッチアクションを有効化
                    UIApplication.shared.endIgnoringInteractionEvents()
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
        
        self.setSectionIndexCellType()
        
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
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID, "17a73169a9326a325c38836f01f7624c"]
        self.bannerView.load(request)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // セルの内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.cellType[indexPath.section][indexPath.row] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "DetailCell", for: indexPath) as! NoticeCustomViewDetailCell
            cell.titleLabel?.text = self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].classname
            cell.subtitleLabel?.text = self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].person
            cell.classificationLabel?.text = NSLocalizedString("lectureNotice-item-classification", comment: "講義案内:分類") + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].classification
            cell.timeLabel?.text = NSLocalizedString("lectureNotice-item-time", comment: "講義案内:時限") + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].time
            cell.placeLabel?.text = NSLocalizedString("lectureNotice-item-place", comment: "講義案内:教室") + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].place
            cell.noteLabel?.text = NSLocalizedString("lectureNotice-item-note", comment: "講義案内:備考") + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].note
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].classname
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
