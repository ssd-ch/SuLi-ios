//
//  ClassroomDivideChildViewController.swift
//  SuLi
//
//  Created by ssd_ch on 2017/08/14.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class ClassroomDivideChildViewController: UIViewController, IndicatorInfoProvider {
    
    @IBOutlet weak var label: UILabel!
    
    //ボタンのタイトル
    var itemTitle = "N/A"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        label.text = self.itemTitle
    }
    
    //ボタンの情報を返す
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: self.itemTitle)
    }
}
