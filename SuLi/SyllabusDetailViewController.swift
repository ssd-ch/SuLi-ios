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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.basic.count+tableData.detail.count+tableData.teachers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < tableData.basic.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            cell.textLabel?.text = tableData.basic[indexPath.row].0
            cell.detailTextLabel?.text = tableData.basic[indexPath.row].1
            return cell
        }
        else if indexPath.row-tableData.basic.count < tableData.detail.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as! SyllabusCustomViewCell
            cell.titleLabel.text = tableData.detail[indexPath.row-tableData.basic.count].0
            cell.detaiLabel.text = tableData.detail[indexPath.row-tableData.basic.count].1
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell3", for: indexPath)
            let reduceCount = tableData.basic.count+tableData.detail.count
            cell.textLabel?.text = tableData.teachers[indexPath.row-reduceCount].0
            cell.detailTextLabel?.text = tableData.teachers[indexPath.row-reduceCount].1
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
                            resultData.detail.append((tdTeacher[i].text!, tdTeacher[i+1].text!))
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
