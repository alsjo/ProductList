//
//  SeperatorTableViewCell.swift
//  ProductList
//
//  Created by vitalii on 29.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit
import SwiftHEXColors

struct SeperatorTableViewCellConfig : BaseCellConfig {
    var insets : UIEdgeInsets?
    var backgroundColor : UIColor?
}

class SeperatorTableViewCell: UITableViewCell {
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(config : SeperatorTableViewCellConfig?){
        if let insets = config?.insets  {
            bottom.constant = insets.bottom
            top.constant = insets.top
            trailing.constant = insets.right
            leading.constant = insets.left
        }
        
        self.seperatorView.backgroundColor = config?.backgroundColor
    }
}
