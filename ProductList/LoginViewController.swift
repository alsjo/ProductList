//
//  LoginViewController.swift
//  ProductList
//
//  Created by vitalii on 04.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit
import JGProgressHUD

class LoginViewController: UIViewController {
	@IBOutlet weak var lbPwError: UILabel!
	@IBOutlet weak var lbUnameError: UILabel!
	@IBOutlet weak var btRegister: UIButton!
	@IBOutlet weak var btSkip: UIButton!
	@IBOutlet weak var btLogin: UIButton!
	@IBOutlet weak var tfUname: UITextField!
	@IBOutlet weak var tfPwd: UITextField!
	@IBOutlet weak var containerView: UIView!
	
	var dataProvider: DataProviderProtocol = DataProvider.shared
	var uname = ""
	var pw = ""
	let hud = JGProgressHUD()
	var keyboardIsShown: Bool = false
	
	override func viewDidLoad() {
        super.viewDidLoad()
		containerView.layer.cornerRadius = 10
		notificationCenterHandler()
		let bar = UIToolbar()
		let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped))
		bar.items = [done]
		bar.sizeToFit()
		tfUname.inputAccessoryView = bar
		tfPwd.inputAccessoryView = bar
		tfUname.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
		tfPwd.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
		tfPwd.delegate = self
		tfUname.delegate = self
        // Do any additional setup after loading the view.
		
		

    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tfPwd.text = ""
		lbPwError.text = ""
		lbUnameError.text = ""
		btLogin.isEnabled = false
		btRegister.isEnabled = false
		self.dataProvider.database.clearIfNeeded()
		if dataProvider.dataStore.isLoggedIn {
			goToProducts()
		}
	}
	
	deinit {
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
		NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
	}
	
	@objc func doneTapped() {
		hideKeyboard()
	}
    
	func disableButtons(){
		self.btLogin.isEnabled = false
		self.btSkip.isEnabled = false
		self.btRegister.isEnabled = false
	}
	
	func enableButtons(){
		self.btLogin.isEnabled = true
		self.btSkip.isEnabled = true
		self.btRegister.isEnabled = true
	}
	
	func goToProducts(){
		let sampleStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let poductsViewController = sampleStoryBoard.instantiateViewController(withIdentifier: "ProductsViewController") as! ProductsViewController
		DispatchQueue.main.async { [weak self] in
			self?.navigationController?.pushViewController(poductsViewController, animated: true)
		}
	}
	
	func checkLoginInput() -> Bool {
		if let error = checkUname(text: tfUname.text) {
			lbUnameError.text = error
			return false
		}else{
			lbUnameError.text = ""
		}
		
		if let error = checkPw(text: tfPwd.text) {
			lbPwError.text = error
			return false
		}
		else{
			lbPwError.text = ""
		}
		return true
	}
	
	private func checkUname(text: String?) -> String? {
		guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return nil}
		if text == "" {
			return "Username is empty"
		}
		
		if !(text.first?.isLetter ?? false) {
			return "Username should begin with letter"
		}
		
		if text.count < 4  {
			return "Username is too short"
		}
		
		if text.count > 20 {
			return "Username is too long"
		}
		
		return nil
	}
	
	private func checkPw(text: String?) -> String? {
		guard let text = text?.trimmingCharacters(in: .whitespacesAndNewlines) else {return nil}
		
		if text == "" {
			return "Password is empty"
		}
		
		if text.count < 4  {
			return "Password is too short"
		}
		
		if text.count > 20 {
			return "Password is too long"
		}
		
		return nil
	}
	
	// MARK: NOTIFICATION CENTER
	
	func notificationCenterHandler() {
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
	
	@IBAction func pwDidEndEditing(_ sender: UITextField) {
		textFieldDidEndEditing(sender)
		pw = sender.text ?? ""
		
		if checkLoginInput() == true {
			btLogin.isEnabled = true
			btRegister.isEnabled = true
		}
		else {
			btLogin.isEnabled = false
			btRegister.isEnabled = false
		}
	}
	@IBAction func unameDidEndEditing(_ sender: UITextField) {
		
		textFieldDidEndEditing(sender)
		uname = sender.text ?? ""
		if checkLoginInput() == true {
			btLogin.isEnabled = true
			btRegister.isEnabled = true
		}
		else {
			btLogin.isEnabled = false
			btRegister.isEnabled = false
		}
	}
	@IBAction func btRegisterClick(_ sender: Any) {
		
		if checkLoginInput() == true {
			disableButtons()
			//start loading indicator
			
			hud.show(in: self.view)
			
			dataProvider.sendRegister(uname: uname, pw: pw) { [weak self] (success, error)  in
				DispatchQueue.main.async { [weak self] in
					//stop loading indicator
					self?.hud.dismiss()
					self?.enableButtons()
					if success == true {
						self?.goToProducts()
					}
					else {
						//show register failure
						self?.showError(message: error ?? "Unable to register")
					}
				}
				
			}
		}
	}
	
	@objc func textFieldDidChange(_ textField: UITextField) {
		if checkLoginInput() == true {
			btLogin.isEnabled = true
			btRegister.isEnabled = true
		}
		else {
			btLogin.isEnabled = false
			btRegister.isEnabled = false
		}
	}
	

	@IBAction func btLoginClick(_ sender: Any) {
		if checkLoginInput() == true {
			disableButtons()
			//start loading indicator
			hud.show(in: self.view)
			dataProvider.sendLogin(uname: uname, pw: pw) { [weak self] (success, error) in
				DispatchQueue.main.async { [weak self] in
					//stop loading indicator
					self?.hud.dismiss()
					self?.enableButtons()
					if success == true {
						self?.goToProducts()
					}
					else {
						//show login failure
						self?.showError(message: error ?? "Unable to login")
					}
				}
				
			}
		}
	}
	
	@IBAction func btSkipClick(_ sender: Any) {
		goToProducts()
	}
	/*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate{
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}
