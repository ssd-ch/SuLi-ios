//
//  ViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/04/30.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import SwiftHTTP
import Kanna

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        tableView.delegate = self
        tableView.dataSource = self
        
        accessData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // セルに表示するテキスト
    var tableData : [SyllabusList] = []

    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        
        cell.textLabel?.text = tableData[indexPath.row].lecture
        cell.detailTextLabel?.text = tableData[indexPath.row].teacher
        return cell
    }
    
    func accessData(){
        self.tableData = []
        do {
            let opt = try HTTP.GET("http://gakumuweb1.shimane-u.ac.jp/shinwa/SYOutsideReferSearchList", parameters: ["nendo": "2017", "disp_cnt": "100"])
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                if let doc = HTML(html: response.data, encoding: .shiftJIS)?.css("body tr") {
                    //print("opt finished: \(String(data: response.data, encoding: .shiftJIS))")
                    for i in 1..<doc.count {
                        let td_node = doc[i].css("td")
                        let lecture = (td_node[2].text?.replacingOccurrences(of: "\n|(　／　.*)", with: "", options: NSString.CompareOptions.regularExpression, range: nil))!
                        let teacher = td_node[3].text
                        let link = "http://gakumuweb1.shimane-u.ac.jp" + (td_node[2].css("a").first?["href"]!)!
                        print(link)
                        self.tableData.append(SyllabusList(data: (lecture,teacher!,link)))
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        
                    }
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
}

class SyllabusList {
    var lecture  = ""
    var teacher  = ""
    var link = ""
    
    init(data: (String,String,String)){
        lecture = data.0
        teacher = data.1
        link = data.2
    }
}

