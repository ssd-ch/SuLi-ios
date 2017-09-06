//
//  ShareFolderView.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/21.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import TOSMBClient

class ShareFolderViewContoller : UIViewController, UITableViewDataSource, UITableViewDelegate {

    var path = NSLocalizedString("shareStorage-rootPath", tableName: "ResourceAddress", comment: "共有ストレージの最初に表示する階層")
    
    @IBOutlet weak var tableView: UITableView!
    
    var files:[Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //テーブルビューデリゲート
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.files = try! SMBSessionController.session?.requestContentsOfDirectory(atFilePath: self.path)
    }
    
    // セルの行数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.files!.count
    }
    
    // セルの内容を返す
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = (self.files?[indexPath.row] as! TOSMBSessionFile).name
        return cell
    }
    
    // セルが選択された時の処理
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //フォルダとファイルで遷移するビューを切り替える
        if (self.files?[indexPath.row] as! TOSMBSessionFile).directory {
            let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "ShareFolderView") as! ShareFolderViewContoller
            nextViewController.path = (self.files?[indexPath.row] as! TOSMBSessionFile).filePath
            nextViewController.navigationItem.title = (self.files?[indexPath.row] as! TOSMBSessionFile).name
            self.show(nextViewController, sender: nil)
        }
        else {
            let nextViewController = self.storyboard!.instantiateViewController(withIdentifier: "ShareFileView") as! ShareFileViewController
            nextViewController.atPath = (self.files?[indexPath.row] as! TOSMBSessionFile).filePath
            nextViewController.navigationItem.title = (self.files?[indexPath.row] as! TOSMBSessionFile).name
            self.show(nextViewController, sender: nil)
        }
    }
}
