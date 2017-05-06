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

class ListViewController: UIViewController,UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchBar.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 検索ボタンが押された時に呼ばれる
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        searchBar.showsCancelButton = true
//        self.searchResults = PPAP.filter{
//            // 大文字と小文字を区別せずに検索
//            $0.lowercased().contains(searchBar.text!.lowercased())
//        }
        searchSyllabus(searchWord: searchBar.text!)
        //self.tableView.reloadData()
    }
    
    // キャンセルボタンが押された時に呼ばれる
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        self.view.endEditing(true)
        searchBar.text = ""
        //self.tableView.reloadData()
    }
    
    // テキストフィールド入力開始前に呼ばれる
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.showsCancelButton = true
        return true
    }

    // セルに表示するテキスト
    var tableData : [SyllabusList] = []

    // セルの行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableData.count
    }
    
    // セルの内容を変更
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = tableData[indexPath.row].lecture
        cell.detailTextLabel?.text = tableData[indexPath.row].teacher
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        
//        print(tableData[indexPath.row].link)
//        
//        // SecondViewControllerに渡す文字列をセット
//        self.selectedLink = tableData[indexPath.row].link
//        
//        // SecondViewControllerへ遷移するSegueを呼び出す
//        performSegue(withIdentifier: "showDetail",sender: nil)
//        
//    }
    
    // Segueで遷移時の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            let controller = segue.destination as! DetailViewController
            controller.link = tableData[indexPath.row].link
        }
    }
    
    func searchSyllabus(searchWord: String){
        print(searchWord.sjisPercentEncoded)
        self.tableData = []
        do {
            //let opt = try HTTP.GET("http://gakumuweb1.shimane-u.ac.jp/shinwa/SYOutsideReferSearchList?j_name="+searchWord.sjisPercentEncoded)
            let opt = try sjisHTTP.GET("http://gakumuweb1.shimane-u.ac.jp/shinwa/SYOutsideReferSearchList", parameters: ["disp_cnt": "100", "j_name": searchWord])
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return //also notify app of failure as needed
                }
                if let doc = HTML(html: response.data, encoding: .shiftJIS)?.css("body tr") {
                    //print("opt finished: \(String(data: response.data, encoding: .shiftJIS))")
                    if doc.count > 0 {
                        print(response.description)
                        for i in 1..<doc.count {
                            let td_node = doc[i].css("td")
                            let lecture = (td_node[2].text?.replacingOccurrences(of: "\n|(　／　.*)", with: "", options: NSString.CompareOptions.regularExpression, range: nil))!
                            let teacher = td_node[3].text
                            let link = "http://gakumuweb1.shimane-u.ac.jp" + (td_node[2].css("a").first?["href"]!)!
                            self.tableData.append(SyllabusList(data: (lecture,teacher!,link)))
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }else {
                        print(response.description)
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

