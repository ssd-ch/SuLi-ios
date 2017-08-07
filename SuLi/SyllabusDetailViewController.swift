//
//  SyllabusDetailViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/02.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import SwiftHTTP
import Kanna

class SyllabusDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SyllabusDetailDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var link: String?
    var syllabus: GetSyllabus?
    
    var tableData: SyllabusData = SyllabusData()
    
    var sectionIndex = ["basic info", "details", "teacheres"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.syllabus = GetSyllabus(self.link!)
        self.syllabus?.delegate = self
        self.syllabus!.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //リロードデータ用デリゲートメソッド
    func reloadTableData(data: SyllabusData, mode: Bool) {
        self.tableData = data
        self.tableView.reloadData()
    }
    
    //各セクションのデータの個数を返す
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return self.tableData.basic.count
        case 1:
            return self.tableData.detail.count
        case 2:
            return self.tableData.teachers.count
        default:
            return 0
        }
    }
    
    //セクション名を返す
    func tableView(_ tableView:UITableView, titleForHeaderInSection section:Int) -> String? {
        return self.sectionIndex[section]
    }
    
    //セクションの個数を返す
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionIndex.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            cell.textLabel?.text = self.tableData.basic[indexPath.row].0
            cell.detailTextLabel?.text = self.tableData.basic[indexPath.row].1
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! SyllabusCustomViewCell
            cell.titleLabel.text = self.tableData.detail[indexPath.row].0
            cell.detaiLabel.text = self.tableData.detail[indexPath.row].1
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath)
            cell.textLabel?.text = self.tableData.teachers[indexPath.row].0
            cell.detailTextLabel?.text = self.tableData.teachers[indexPath.row].1
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            cell.textLabel?.text = "N/A"
            cell.detailTextLabel?.text = "N/A"
            return cell
        }
    }
    
}

protocol SyllabusDetailDelegate {
    
    func reloadTableData(data: SyllabusData, mode: Bool) -> Void
}

class GetSyllabus {
    
    var URL = ""
    var loadingStatus: Bool = true
    
    var delegate: SyllabusDetailDelegate?
    
    init(_ url: String) {
        self.URL = url
    }
    
    func start() {
        
        let resultData = SyllabusData()
        
        do {
            let opt = try HTTP.GET(self.URL)
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                if let doc = HTML(html: response.data, encoding: .shiftJIS)?.css("table.normal") {
                    if doc.count >= 3 {
                        
                        //基本データ
                        let thBasic = doc[0].css("th")
                        let tdBasic = doc[0].css("td")
                        
                        for i in 0..<thBasic.count {
                            resultData.basic.append((thBasic[i].text!, tdBasic[i].text!))
                        }
                        
                        //講義内容
                        let thDetail = doc[1].css("th")
                        let tdDetail = doc[1].css("td")
                        
                        for i in 0..<thDetail.count {
                            let text = tdDetail[i].toHTML!.replaceAll(pattern: "<br>", with: "\n")
                            resultData.detail.append((thDetail[i].text!, HTML(html: text, encoding: .utf8)!.text!))
                        }
                        
                        //担当教員
                        let tdTeacher = doc[2].css("td")
                        
                        for i in stride(from: 0, to: tdTeacher.count, by: 2) {
                            resultData.teachers.append((tdTeacher[i].text!, tdTeacher[i+1].text!))
                        }
                        
                        //メインスレッドで呼び出す
                        DispatchQueue.main.async {
                            self.delegate?.reloadTableData(data: resultData, mode: false)
                        }
                    }else {
                        DispatchQueue.main.async {
                            self.delegate?.reloadTableData(data: resultData, mode: false)
                        }
                    }
                }
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
}

class SyllabusData {
    
    var basic: [(String,String)]
    var detail: [(String,String)]
    var teachers: [(String,String)]
    
    init() {
        basic = []
        detail = []
        teachers = []
    }
}
