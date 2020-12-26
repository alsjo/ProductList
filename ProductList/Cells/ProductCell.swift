//
//  ProductCell.swift
//  ProductList
//
//  Created by vitalii on 04.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {

	@IBOutlet weak var ivProductImage: UIImageView!
	@IBOutlet weak var tvDescription: UITextView!
	@IBOutlet weak var lbTitle: UILabel!


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
	
	override func awakeFromNib() {
		super.awakeFromNib()
		// Initialization code
		self.tvDescription.text = ""
		self.lbTitle.text = ""
		self.ivProductImage.layer.cornerRadius = 5
	}
	

	
	override func prepareForReuse() {
		DispatchQueue.main.async {  [unowned self] in
			self.ivProductImage.image = nil
			self.ivProductImage.backgroundColor = UIColor.randomColor()
			self.tvDescription.text = ""
			self.lbTitle.text = ""
			
		}
	}
	
	func updateTitle(row: Int, section: Int, title: String?, animated: Bool = true) {
		
		DispatchQueue.main.async { [weak self] in
			
			let title = title ?? self?.lbTitle.text ?? ""
			if animated {
				UIView.animate(withDuration: 0.2) {
					self?.lbTitle.text = title
					//self?.lbTitle.text = "\(section)-\(row) \(title)"
				}
			} else {
				self?.lbTitle.text = title
				//self?.lbTitle.text = "\(section)-\(row) \(title)"
			}
			
		}
	}
	
	func updateDescription(description: String, animated: Bool = true) {
		DispatchQueue.main.async { [weak self] in
			if animated {
				UIView.animate(withDuration: 0.2) {
					self?.tvDescription.text = description
				}
			} else {
				self?.tvDescription.text = description
			}
			
		}
	}
	
	func updateImage(image: UIImage, animated: Bool = true, row: Int = -1, section: Int = -1) {
		DispatchQueue.main.async { [weak self] in
			//			if(row > -1 && section > -1) {
			//				print("updating image at \(section)-\(row)")
			//			}
			if animated {
				UIView.animate(withDuration: 0.2) {
					self?.ivProductImage.image = image
				}
			} else {
				self?.ivProductImage.image = image
			}
			//self.ivComicCover.layer.cornerRadius = 5
		}
	}

}
