//
//  MaterialViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/10/10.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

class MaterialViewContoller : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        (segue.destination as? WebViewContoller)?.link = NSLocalizedString(segue.identifier!, tableName: "ResourceAddress", comment: "URL")
    }
}
