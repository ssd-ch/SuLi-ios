//
//  SyllabusCustomBasicCell.swift
//  SuLi
//
//  Created by ssd_ch on 2017/12/31.
//  Copyright © 2017年 ssd. All rights reserved.
//

import UIKit

class SyllabusCustomBasicCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
