//
//  ProfileViewController.swift
//  ProductList
//
//  Created by vitalii on 04.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

	@IBOutlet weak var tfName: UITextField!
	@IBOutlet weak var ivPortrait: UIImageView!
	
	var imagePicker: ImagePicker!
	var dataProvider: DataProviderProtocol = DataProvider.shared
	var keyboardIsShown: Bool = false

	override func viewDidLoad() {
        super.viewDidLoad()
		setupNotificationCenterHandler()
		 self.imagePicker = ImagePicker(presentationController: self, delegate: self)
		setupNameTextField()
		
		fillUpProfile()
		self.navigationItem.title = "Profile"
        // Do any additional setup after loading the view.
    }
	deinit {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	@objc func doneTapped() {
		hideKeyboard()
	}
	@objc func textFieldDidChange(_ textField: UITextField) {
		
	}
	
	fileprivate func setupNameTextField() {
		let bar = UIToolbar()
		let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
		bar.items = [done]
		bar.sizeToFit()
		tfName.inputAccessoryView = bar
		tfName.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
		tfName.delegate = self
	}
	fileprivate func fillUpProfile() {
		if let image = dataProvider.dataStore.userProfile?.portrait {
			self.ivPortrait.image = image
		}
		
		if let fullName = dataProvider.dataStore.userProfile?.fullName {
			self.tfName.text = fullName
		}
	}
	@IBAction func nameOnEndEditing(_ sender: UITextField) {
		textFieldDidEndEditing(sender)
		if let name = sender.text {
			if name.count > 0
			{
				var count = name.count
				if count > 20 { count = 20 }
				let index = name.index(name.startIndex, offsetBy: count)
				dataProvider.setProfileName(name: name.substring(to: index))
			}
		}
	}
	@IBAction func nameOnBeginEditing(_ sender: UITextField) {
		UIView.animate(withDuration: 1) {
			sender.layer.borderWidth = 1
			sender.layer.borderColor = UIColor.systemBlue.cgColor
		}
	}
	@IBAction func btLogoutClick(_ sender: Any) {
		dataProvider.dataStore.logout()
		self.navigationController?.popToRootViewController(animated: true)
	}
	@IBAction func btChangePortraitClick(_ sender: UIButton) {
		self.imagePicker.present(from: sender)
	}
	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
	
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
			view.frame.origin.y -= 150
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
	
	@IBAction func textFieldDidBeginEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 1) {
			textField.layer.borderWidth = 1
			textField.layer.borderColor = UIColor.systemBlue.cgColor
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		UIView.animate(withDuration: 1) {
			textField.layer.borderWidth = 0
		}
	}

}

extension ProfileViewController: UITextFieldDelegate{
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}

extension ProfileViewController: ImagePickerDelegate {
	
	func didSelect(image: UIImage?) {
		if let image = image {
			self.ivPortrait.image = image
			self.dataProvider.setProfilePortrait(image: image)
		}
	}
}
