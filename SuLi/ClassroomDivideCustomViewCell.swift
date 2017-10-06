//
//  ClassroomDivideCustomViewCell.swift
//  SuLi
//
//  Created by ssd_ch on 2017/10/05.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

class ClassroomDivideCustomViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
