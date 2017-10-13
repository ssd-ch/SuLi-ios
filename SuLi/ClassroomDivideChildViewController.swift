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
    var sectionIndex = [NSLocalizedString("classroom-section-1", comment: "教室配当表のセクション名:1コマ"),
                        NSLocalizedString("classroom-section-2", comment: "教室配当表のセクション名:2コマ"),
                        NSLocalizedString("classroom-section-3", comment: "教室配当表のセクション名:3コマ"),
                        NSLocalizedString("classroom-section-4", comment: "教室配当表のセクション名:4コマ"),
                        NSLocalizedString("classroom-section-5", comment: "教室配当表のセクション名:5コマ")]
    
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
        let cellText = self.classroomDivide.filter("time = \(indexPath.section + 1)")[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ClassroomDivideCustomViewCell
        cell.titleLabel?.text = cellText.cell_text
        cell.titleLabel?.textColor = UIColor.hex(hexStr: cellText.cell_color, alpha: 1)
        cell.detailLabel?.text = cellText.place
        cell.colorView?.backgroundColor = UIColor.hex(hexStr: (self.realm.objects(Building.self).filter("id = \(cellText.building_id)").first?.color)!, alpha: 1)
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
