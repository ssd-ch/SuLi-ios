//
//  ClassroomListVIewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/05/23.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

class ClassroomListViewContoroller: UIViewController {
    
 
    @IBAction func pushReloadButton(_ sender: Any) {
        let downloader = GetClassroomList()
        downloader.start()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}
