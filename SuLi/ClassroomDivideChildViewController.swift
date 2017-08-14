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
    
    //CancelInfoオブジェクト
    var classroomDivide: Results<ClassroomDivide>!
    
    //タブのボタンのタイトル
    var itemTitle = "N/A"
    
    //表示するデータ(曜日)
    var weekday = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //ClassroomDivideのすべてのオブジェクトを取得
        self.classroomDivide = self.realm.objects(ClassroomDivide.self).filter("weekday = \(self.weekday)")
        
        //テーブルビューデリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    //タブのボタンの情報を返す
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.itemTitle)
    }
    
    //セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.classroomDivide.count
    }
    
    //セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.classroomDivide[indexPath.row].cell_text
        cell.detailTextLabel?.text = self.classroomDivide[indexPath.row].place
        return cell
    }
    
    //データを更新
    func updateData(){

        //ClassroomDivideのすべてのオブジェクトを取得
        self.classroomDivide = self.realm.objects(ClassroomDivide.self).filter("weekday = \(self.weekday)")

        //テーブルを更新
        self.tableView.reloadData()
    }
    
}
