//
//  WorkFolderView.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/21.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import TOSMBClient

class WorkFolderViewContoller : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let host = "cosmos.shimane-u.ac.jp"
    let ip = "10.16.1.16"
    var id = ""
    var password = ""
    var path = "/"
    
    @IBOutlet weak var tableView: UITableView!
    
    var files:[Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブルビューデリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let session = TOSMBSession(hostName: self.host, ipAddress: self.ip)
        session?.setLoginCredentialsWithUserName(self.id, password: self.password)
        
        self.files = try! session?.requestContentsOfDirectory(atFilePath: self.path)
    }
    
    // セルの行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files!.count
    }
    
    // セルの内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        cell.textLabel?.text = (self.files?[indexPath.row] as! TOSMBSessionFile).name
        return cell
    }
    
    // Segueで遷移時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let controller = segue.destination as! WorkFolderViewContoller
            controller.id = self.id
            controller.password = self.password
            controller.path = (self.files?[indexPath.row] as! TOSMBSessionFile).filePath
            controller.navigationItem.title = (self.files?[indexPath.row] as! TOSMBSessionFile).name
        }
    }
}
