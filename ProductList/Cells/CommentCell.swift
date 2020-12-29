//
//  CommentCell.swift
//  ProductList
//
//  Created by vitalii on 04.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit
import Cosmos
class CommentCell: UITableViewCell {
	@IBOutlet weak var tvHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var ratingView: CosmosView!
	@IBOutlet weak var ivImage: UIImageView!
	@IBOutlet weak var lbName: UILabel!
	@IBOutlet weak var lbText: UILabel!
	@IBOutlet weak var tvText: UITextView!
	
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//		self.lbText.text = ""
//		//setupRatingView()
//		//initUI()
//		//self.tvText.translatesAutoresizingMaskIntoConstraints = true
//
//		//self.tvText.isScrollEnabled = false
//		//self.layoutIfNeeded()
//    }
//
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//		//self.sele
//        // Configure the view for the selected state
//    }
//
//	override func prepareForReuse() {
//		//self.layoutIfNeeded()
//		DispatchQueue.main.async {  [weak self] in
//
//		//	self?.ratingView.rating = 0.0
//		//	self?.lbText.text = ""
//			//self?.tvText.text = ""
//			//self?.tvText.sizeToFit()
//			//self?.updateTextViewHeight(animated: false)
//			//self?.ratingView.text = ""
//			//self?.initUI()
//			//self?.layoutIfNeeded()
//		}
//	}
//
//	func initUI(){
//		self.lbText.text = ""
//		self.tvText.text = ""
//		//self.tvText.sizeToFit()
//		//self.tvText.sizeToFit()
//		self.lbName.text = ""
//		//self.ivImage.layer.cornerRadius = 40
//		self.ivImage.image = blankFace
//		//self?.tvText.sizeToFit()
//		//self.updateTextViewHeight(animated: false)
//	}
//
//	func updateName(name: String?, row: Int = -1,  animated: Bool = true) {
//
//		DispatchQueue.main.async { [weak self] in
//
//			let title = name ?? self?.lbName.text ?? ""
//			if animated {
//				UIView.animate(withDuration: 0.2) {
//					self?.lbName.text = title
//					//self?.lbTitle.text = "\(section)-\(row) \(title)"
//				}
//			} else {
//				self?.lbName.text = title
//				//self?.lbTitle.text = "\(section)-\(row) \(title)"
//			}
//
//		}
//	}
//
//	func updateText(text: String, animated: Bool = true) {
//		DispatchQueue.main.async { [weak self] in
//			if animated {
//				UIView.animate(withDuration: 0.2) {
//					self?.tvText.text = text
//					self?.lbText.text = text
//				}
//			} else {
//				self?.tvText.text = text
//				self?.lbText.text = text
//			}
//			//self?.contentView.layoutIfNeeded()
//			//self?.tvText.sizeToFit()
//			//self?.updateTextViewHeight(animated: animated)
//		}
//	}
//
//	func updateTextViewHeight(animated: Bool) {
//		let textContainterInsets = self.tvText.textContainerInset
//		let usedRect = self.tvText.layoutManager.usedRect(for: self.tvText.textContainer)
//
//		// This is a reference to the constraint defined in storyboard
//		self.tvHeightConstraint.constant = usedRect.size.height + textContainterInsets.top + textContainterInsets.bottom
//
//		// animate if desired
//		if !animated { return }
//		UIView.animate(withDuration: 0.2, animations: {
//			self.contentView.layoutIfNeeded()
//		})
//	}
//
//	func updateImage(image: UIImage, animated: Bool = true, row: Int = -1) {
//		DispatchQueue.main.async { [weak self] in
//			if animated {
//				UIView.animate(withDuration: 0.2) {
//					self?.ivImage.image = image
//				}
//			} else {
//				self?.ivImage.image = image
//			}
//		}
//	}
//
//	func updateRating(rating: Int, animated: Bool = true, row: Int = -1) {
//		DispatchQueue.main.async { [weak self] in
//			if animated {
//				UIView.animate(withDuration: 0.2) {
//					self?.ratingView.rating = Double(rating)
//
//					self?.ratingView.text = "\(rating)/5"
//				}
//			} else {
//				self?.ratingView.rating = Double(rating)
//				self?.ratingView.text = "\(rating)/5"
//			}
//		}
//	}
//
//
//
//
//	func setupRatingView(){
//		// Do not change rating when touched
//		// Use if you need just to show the stars without getting user's input
//		ratingView.settings.updateOnTouch = false
//
//		// Show only fully filled stars
//		ratingView.settings.fillMode = .full
//		// Other fill modes: .half, .precise
//
//		// Change the size of the stars
//		ratingView.settings.starSize = 15
//
//		// Set the distance between stars
//		ratingView.settings.starMargin = 2
//
//		// Set the color of a filled star
//		ratingView.settings.filledColor = UIColor.orange
//
//		// Set the border color of an empty star
//		ratingView.settings.emptyBorderColor = UIColor.orange
//
//		// Set the border color of a filled star
//		ratingView.settings.filledBorderColor = UIColor.orange
//
//		ratingView.settings.totalStars = 5
//
//		// Change the cosmos view rating
//		ratingView.rating = 4
//
//		// Change the text
//		ratingView.text = "\(ratingView.rating)/\(ratingView.settings.totalStars)"
//
//		// Called when user finishes changing the rating by lifting the finger from the view.
//		// This may be a good place to save the rating in the database or send to the server.
//		ratingView.didFinishTouchingCosmos = { rating in
//			print("on didFinishTouchingCosmos")
//			print("rating: \(rating)")
//		}
//
//		// A closure that is called when user changes the rating by touching the view.
//		// This can be used to update UI as the rating is being changed by moving a finger.
//		ratingView.didTouchCosmos = { rating in
//			print("on didTouchCosmos")
//		}
//	}
}
