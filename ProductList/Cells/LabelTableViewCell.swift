//
//  LabelTableViewCell.swift
//  ProductList
//
//  Created by vitalii on 29.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit
import Nantes

struct LabelTableViewCellConfig: BaseCellConfig {
    var insets : UIEdgeInsets?
    var backgroundColor : UIColor?
    var labelText : NSAttributedString?
    var alignment : NSTextAlignment?
    var links : [(URL,NSRange)]?
	var font : UIFont?
	var textColor : UIColor?
}

protocol LabelTableViewCellDelegate : class {
    func didSelectLinkWith(url: URL!)
}

class LabelTableViewCell: UITableViewCell, NantesLabelDelegate {
    @IBOutlet weak var top: NSLayoutConstraint!
    @IBOutlet weak var bottom: NSLayoutConstraint!
    @IBOutlet weak var leading: NSLayoutConstraint!
    @IBOutlet weak var trailing: NSLayoutConstraint!
    
    @IBOutlet weak var label: NantesLabel!
    weak var delegate : LabelTableViewCellDelegate?
	private var config : LabelTableViewCellConfig?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(config : LabelTableViewCellConfig?){
		self.config = config
        if let insets = config?.insets  {
            bottom.constant = insets.bottom
            top.constant = insets.top
            trailing.constant = insets.right
            leading.constant = insets.left
        }
        
        label.linkAttributes = [NSAttributedString.Key.foregroundColor : AppManager.appStyle.color(for: .link)]
        
        if let text = config?.labelText  {
            label.attributedText = text
        }
        
        if let alignment = config?.alignment{
            label.textAlignment = alignment
        }
        
        if let links = config?.links{
            links.forEach { (url, range) in
				label.addLink(to: url, withRange: range)
                
            }
            
            label.delegate = self
        }
        
        if let bgColor = config?.backgroundColor {
            label.backgroundColor = bgColor
        }
		
		if let font = config?.font{
			label.font = font
		}
		if let textColor = config?.textColor{
			label.textColor = textColor
		}
		hideLabel()
    }
	
	func showText(str : NSAttributedString){
		if(str.string.isEmpty){
			//hide
			self.hideLabel()
			self.contentView.backgroundColor = UIColor.clear
		}
		else{
			self.showLabel(str: str)
			if let bgColor = config?.backgroundColor{
				//DispatchQueue.main.async { [weak self] in
					self.contentView.backgroundColor = bgColor
				//}
			}
			else{
			//	DispatchQueue.main.async { [weak self] in
					self.contentView.backgroundColor = UIColor.clear
			//	}
			}
		}
	}
	
	func showLabel(str : NSAttributedString){
		//DispatchQueue.main.async { [weak self] in
			self.label.isHidden = false
			self.label.attributedText = str
		//}
	}
	
	func hideLabel(){
		//DispatchQueue.main.async { [weak self] in
			self.label.isHidden = true
			self.label.attributedText = NSAttributedString(string: "No error")
		//}
	}
    
    func attributedLabel(_ label: NantesLabel!, didSelectLinkWith url: URL!) {
        delegate?.didSelectLinkWith(url: url)
    }
}
