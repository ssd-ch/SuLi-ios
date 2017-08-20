//
//  ClassroomDivideChildViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/14.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import RealmSwift
import XLPagerTabStrip

class ClassroomDivideChildViewController: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    //Realmインスタンス
    let realm = try! Realm()
    
    //CancelDivideオブジェクト
    var classroomDivide: Results<ClassroomDivide>!
    
    //タブのボタンのタイトル
    var itemTitle = "N/A"
    
    //表示するデータの条件
    static let allData = -1
    var weekday = ClassroomDivideChildViewController.allData //曜日
    var buildingId = ClassroomDivideChildViewController.allData //建物
    
    //セクション
    var sectionIndex = ["1.2 period", "3.4 period", "5.6 period", "7.8 period", "9.10 period"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ClassroomDivideのすべてのオブジェクトを取得
        self.classroomDivide = self.realm.objects(ClassroomDivide.self).filter("weekday = \(self.weekday)").sorted(byKeyPath: "id")
        
        //建物の指定がある場合は絞り込みを行う
        if buildingId != ClassroomDivideChildViewController.allData {
            self.classroomDivide = self.classroomDivide.filter("building_id = \(self.buildingId)")
        }
        
        //テーブルビューデリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //タブのボタンの情報を返す
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.itemTitle)
    }
    
    //セルの内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.classroomDivide.filter("time = \(indexPath.section + 1)")[indexPath.row].cell_text
        //空文字だとlabelが生成されず高さがバラバラになるのでとりあえずの処置
        if cell.textLabel?.text == "" {
            cell.textLabel?.text = " "
        }
        cell.textLabel?.textColor = UIColor.hex(hexStr: self.classroomDivide.filter("time = \(indexPath.section + 1)")[indexPath.row].cell_color, alpha: 1)
        cell.detailTextLabel?.text = self.classroomDivide.filter("time = \(indexPath.section + 1)")[indexPath.row].place
        return cell
    }
    
    //セクション名を返す
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        return sectionIndex[section]
    }
    
    //各セクションのデータの個数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classroomDivide.filter("time = \(section + 1)").count
    }
    
    //セクションの個数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionIndex.count
    }
    
    //スクロールの禁止
    func rockAccess() {
        //スクロールの禁止
        if self.tableView != nil {
            self.tableView.isScrollEnabled = false
        }
    }
    
    //データを更新
    func updateData() {
        
        //ClassroomDivideのすべてのオブジェクトを取得
        self.classroomDivide = self.realm.objects(ClassroomDivide.self).filter("weekday = \(self.weekday)").sorted(byKeyPath: "id")
        
        //建物の指定がある場合は絞り込みを行う
        if buildingId != ClassroomDivideChildViewController.allData {
            self.classroomDivide = self.classroomDivide.filter("building_id = \(self.buildingId)")
        }
        
        //テーブルを更新
        if self.tableView != nil {
            print("ClassroomDivideChildViewController: No.\(self.weekday) update table data")
            //スクロールの許可
            self.tableView.isScrollEnabled = true
            //データの更新
            self.tableView.reloadData()
        }
    }
    
}
