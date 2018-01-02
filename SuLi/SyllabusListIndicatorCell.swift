//
//  SyllabusListIndicatorCell.swift
//  SuLi
//
//  Created by ssd_ch on 2018/01/03.
//  Copyright © 2018年 ssd. All rights reserved.
//

import UIKit

class SyllabusListIndicatorCell: UITableViewCell {
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
