//
//  NoticeViewContoller.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/12.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import RealmSwift

class NoticeViewContoller : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //CancelInfoオブジェクト
    let cancelInfo = try! Realm().objects(CancelInfo.self).sorted(byKeyPath: "id")
    
    //セルの種類(true:DetailCell false:Cell)
    var cellType = [[Bool]]()
    
    //セクション
    var sectionIndex: [(String, Int)] = []
    
    //リロードボタンが押された時の処理
    @IBAction func pushReloadButton(_ sender: Any) {
        //スクロールを禁止
        self.tableView.isScrollEnabled = false
        
        //スレッドを管理するグループを作成
        var groupDispatch = DispatchGroup()
        
        //スレッドの登録
        groupDispatch.enter()
        
        //処理が完了したら通知させるディスパッチを参照で渡して更新処理を始める
        GetCancelInfo.start(groupDispatch: &groupDispatch)
        
        //処理が完了したらCancelInfoを更新
        groupDispatch.notify(queue: DispatchQueue.main) {
            print("NoticeViewController : get cancelInfo in Realm")
            //セルの状態を初期化
            self.cellType = []
            self.setSectionIndex()
            for i in 0..<self.sectionIndex.count {
                self.cellType.append([Bool]())
                for _ in 0..<self.sectionIndex[i].1 {
                    self.cellType[i].append(false)
                }
            }
            self.tableView.reloadData()
            self.tableView.isScrollEnabled = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //セクションを作成
        self.setSectionIndex()
        
        //セルの状態を初期化
        for i in 0..<self.sectionIndex.count {
            self.cellType.append([Bool]())
            for _ in 0..<self.sectionIndex[i].1 {
                self.cellType[i].append(false)
            }
        }
        
        //テーブルビューデリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
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
            cell.classificationLabel?.text = "Classification : " + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].classification
            cell.timeLabel?.text = "Time : " + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].time
            cell.placeLabel?.text = "Place : " + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].place
            cell.noteLabel?.text = "Note : " + self.cancelInfo.filter("date = '\(self.sectionIndex[indexPath.section].0)'")[indexPath.row].note
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
    
    func setSectionIndex() {
        
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
    }
    
}
