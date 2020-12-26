//
//  CommentInputViewController.swift
//  ProductList
//
//  Created by vitalii on 04.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit
import Cosmos
class CommentInputViewController: UIViewController {

	@IBOutlet weak var ratingView: CosmosView!
	@IBOutlet weak var tvText: UITextView!
	@IBOutlet weak var btSave: UIButton!
	@IBOutlet weak var containerView: UIView!
	
	var onSubmit:((Int, String) -> ())?
	var rating: Double = 0.0
	var text: String = ""
	var keyboardIsShown: Bool = false

	
	override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
		self.view.backgroundColor = UIColor.clear
		self.view.isOpaque = false
		containerView.layer.cornerRadius = 10
		setupNotificationCenterHandler()
		setupInputView()
		setupRatingView()
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tvText.text = ""
		tvText.becomeFirstResponder()
		ratingView.rating = 0
		btSave.isEnabled = false
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	fileprivate func setupInputView() {
		let bar = UIToolbar()
		let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
		bar.items = [done]
		bar.sizeToFit()
		tvText.text = ""
		tvText.inputAccessoryView = bar
		self.tvText.layer.borderColor = UIColor.systemGray4.cgColor
		self.tvText.layer.borderWidth = 1
		self.tvText.layer.cornerRadius = 10
	}
	
	@objc func doneTapped() {
		hideKeyboard()
	}
	
	// MARK: NOTIFICATION CENTER
	
	func setupNotificationCenterHandler() {
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		hideKeyboardOnTap()
	}
	
	@objc func handleKeyboardWillShow(notification: NSNotification){
		let kDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
		guard let duration = kDuration else { return }
		if !keyboardIsShown {
			view.frame.origin.y -= 50
		}
		UIView.animate(withDuration: duration) {
			self.view.layoutIfNeeded()
		}
		keyboardIsShown = true
	}
	
	@objc func handleKeyboardWillHide(notification: NSNotification){
		let kDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
		guard let duration = kDuration else { return }
		view.frame.origin.y = 0
		keyboardIsShown = false
		UIView.animate(withDuration: duration) {
			self.view.layoutIfNeeded()
		}
	}
	
	private func hideKeyboardOnTap(){
		let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
		tap.cancelsTouchesInView = false
		view.addGestureRecognizer(tap)
	}
	
	@objc private func hideKeyboard(){
		view.endEditing(true)
		keyboardIsShown = false
	}
	
	func setupRatingView(){
		// Do not change rating when touched
		// Use if you need just to show the stars without getting user's input
		ratingView.settings.updateOnTouch = true
		
		// Show only fully filled stars
		ratingView.settings.fillMode = .full
		// Other fill modes: .half, .precise
		
		// Change the size of the stars
		ratingView.settings.starSize = 30
		
		// Set the distance between stars
		ratingView.settings.starMargin = 2
		
		// Set the color of a filled star
		ratingView.settings.filledColor = UIColor.orange
		
		// Set the border color of an empty star
		ratingView.settings.emptyBorderColor = UIColor.orange
		
		// Set the border color of a filled star
		ratingView.settings.filledBorderColor = UIColor.orange
		
		ratingView.settings.totalStars = 5
		
		// Change the cosmos view rating
		ratingView.rating = 0
		
		// Change the text
		ratingView.text = ""
		
		// Called when user finishes changing the rating by lifting the finger from the view.
		// This may be a good place to save the rating in the database or send to the server.
		ratingView.didFinishTouchingCosmos = { [weak self] rating in
			print("on didFinishTouchingCosmos")
			print("rating: \(rating)")
			self?.rating = rating
			self?.btSave.isEnabled = true
		}
		
		// A closure that is called when user changes the rating by touching the view.
		// This can be used to update UI as the rating is being changed by moving a finger.
		ratingView.didTouchCosmos = { rating in
			print("on didTouchCosmos")
		}
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	@IBAction func btSaveClick(_ sender: Any) {
		text = tvText.text
		if let completion = onSubmit {
			completion(Int(rating), text)
		}
		dismiss(animated: true, completion: nil)
		
	}
	@IBAction func btCancelClick(_ sender: Any) {
		dismiss(animated: true, completion: nil)
	}
	
}


//extension LoginViewController: UITextViewDelegate{
//	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//		self.view.endEditing(true)
//		return false
//	}
//}
