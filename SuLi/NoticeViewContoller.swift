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
    
    //Realmインスタンス
    let realm = try! Realm()
    
    //CancelInfoオブジェクト
    var cancelInfo: Results<CancelInfo>!
    
    //リロードボタンが押された時の処理
    @IBAction func pushReloadButton(_ sender: Any) {
        
        //スレッドを管理するグループを作成
        var groupDispatch = DispatchGroup()
        
        //スレッドの登録
        groupDispatch.enter()
        
        //処理が完了したら通知させるディスパッチを参照で渡して更新処理を始める
        GetCancelInfo.start(groupDispatch: &groupDispatch)
        
        //処理が完了したらcancelInfoのすべてのオブジェクトを取得(更新)
        groupDispatch.notify(queue: DispatchQueue.main) {
            self.cancelInfo = self.realm.objects(CancelInfo.self)
            self.tableView.reloadData()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //CancelInfoのすべてのオブジェクトを取得
        self.cancelInfo = self.realm.objects(CancelInfo.self)
        
        //テーブルビューデリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cancelInfo.count
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = self.cancelInfo[indexPath.row].classname
        cell.detailTextLabel?.text = self.cancelInfo[indexPath.row].person
        return cell
    }
    
}
