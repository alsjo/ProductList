//
//  LoginViewController.swift
//  ProductList
//
//  Created by vitalii on 04.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit

protocol LoginDisplayLogic: class{
	func displaySomething(viewModel: Login.Something.ViewModel)
	func displaySignInError(viewModel : Login.SignIn.ErrorViewModel)
	func displaySignUpError(viewModel : Login.SignUp.ErrorViewModel)
	func displayUI(viewModel: Login.UI.ViewModel)
	func displayValidationErrors(viewModel : Login.Validate.ViewModel)
	func displayProducts(viewModel : Login.SignIn.ViewModel)
	func displayProducts(viewModel : Login.SignUp.ViewModel)
}

class LoginView: UIViewController, LoginDisplayLogic, UITableViewDataSource, UITableViewDelegate {
	@IBOutlet weak var tableView: UITableView!
	var interactor: LoginBusinessLogic?
	var router: (NSObjectProtocol & LoginRoutingLogic & LoginDataPassing)?
	private var cellConfigs : [(uiComponent : Login.UIComponents, config: BaseCellConfig)]?
	private var unameCell : TextfieldTableViewCell?
	private var errorCell : LabelTableViewCell?
	private var passwordCell : TextfieldTableViewCell?
	
	var dataProvider: DataProviderProtocol = DataProvider.shared
	
	override func viewDidLoad() {
        super.viewDidLoad()
		doSomething()
		setUpUI()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController?.hideNavigationBar()
		addObserverForLangaugeChange()
		onLaunchSetup()
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setup()
	}
	
	required init?(coder aDecoder: NSCoder){
		super.init(coder: aDecoder)
		setup()
	}
	
	// MARK: Setup
	private func setup(){
		let viewController = self
		let interactor = LoginInteractor()
		let presenter = LoginPresenter()
		let router = LoginRouter()
		viewController.interactor = interactor
		viewController.router = router
		interactor.presenter = presenter
		presenter.viewController = viewController
		router.viewController = viewController
		router.dataStore = interactor
	}
	
	//MARK: Setup
	func setUpUI(){
		hideKeyboardWhenTappedAround()
		registerNibs()
		setupTableView()
		askForUI()
		
	}
	
	func setupTableView(){
		self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
		tableView.dataSource = self
		tableView.delegate = self
		tableView.estimatedRowHeight = 200
		self.tableView.backgroundColor = UIColor.clear
	}
	
	func registerNibs(){
		tableView.register(UINib(nibName: "TextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "unameCell")
		tableView.register(UINib(nibName: "TextfieldTableViewCell", bundle: nil), forCellReuseIdentifier: "passwordCell")
		tableView.register(UINib(nibName: "SeperatorTableViewCell", bundle: nil), forCellReuseIdentifier: "spacerCell")

		tableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "signUpCell")
		tableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "signInCell")
		tableView.register(UINib(nibName: "ButtonTableViewCell", bundle: nil), forCellReuseIdentifier: "skipCell")
		tableView.register(UINib(nibName: "LabelTableViewCell", bundle: nil), forCellReuseIdentifier: "error")
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 140
	}
	
	// MARK: Presenter command
	func doSomething(){
		let request = Login.Something.Request()
		interactor?.doSomething(request: request)
	}
	
	func addObserverForLangaugeChange(){
		NotificationCenter.default.addObserver(self, selector: #selector(self.languageDidChange(notification:)), name: NSNotification.Name.init("languageDidChange"), object: nil)
	}
	
	@objc func languageDidChange(notification: Notification){
		askForUI()
	}
	
	func askForUI(){
		interactor?.requiredUIForScreen(request: Login.UI.Request())
		
	}
	
	func onLaunchSetup(){
		interactor?.onLaunchSetup(request: Login.onLaunch.Request())
	}
	
	func displaySomething(viewModel: Login.Something.ViewModel){
	}
	
	func displayUI(viewModel: Login.UI.ViewModel) {
		cellConfigs = viewModel.cellConfigs
		tableView.reloadData()
	}
	

	
	func displayProducts(viewModel: Login.SignUp.ViewModel) {

		self.removeHud()
	
		router?.routeToProducts()
	}
	
	func displayProducts(viewModel: Login.SignIn.ViewModel) {

		self.removeHud()

		router?.routeToProducts()
	}
	
	func displayProducts(viewModel : Login.Skip.ViewModel) {

		self.removeHud()

		router?.routeToProducts()
	}
	
	func displaySignInError(viewModel : Login.SignIn.ErrorViewModel)
	{
		self.removeHud()
		DispatchQueue.main.async { [weak self] in
			if let error = viewModel.error
			{
				self?.errorCell?.showText(str: error)
			}
			self?.tableView.refresh()
		}
	}
	func displaySignUpError(viewModel : Login.SignUp.ErrorViewModel)
	{
		self.removeHud()
		DispatchQueue.main.async { [weak self] in
			if let error = viewModel.error
			{
				self?.errorCell?.showText(str: error)
			}
			self?.tableView.refresh()
		}
	}
	func displayValidationErrors(viewModel: Login.Validate.ViewModel) {

		self.removeHud()

		if let unameError = viewModel.errorMessageForUname {
			self.unameCell?.showError(str: unameError)
		}
		
		if let pwError = viewModel.errorMessageForPassword {
			self.passwordCell?.showError(str: pwError)
		}
		
		tableView.refresh()
	}
	
	
	//MARK: Tableview source
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return UITableView.automaticDimension
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
		return cellConfigs?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
		guard let cellDetails = cellConfigs?[indexPath.row]  else {
			return UITableViewCell()
		}
		
		switch cellDetails.uiComponent {
		case .spacer :
			let cell = tableView.dequeueReusableCell(withIdentifier: "spacerCell", for: indexPath) as! SeperatorTableViewCell
			cell.backgroundColor = UIColor.clear
			cell.configureCell(config: cellDetails.config as? SeperatorTableViewCellConfig)
			return cell
		case .uname :
			let cell = tableView.dequeueReusableCell(withIdentifier: "unameCell", for: indexPath) as! TextfieldTableViewCell
			self.unameCell = cell
			
			cell.configureCell(config: cellDetails.config as? TextfieldTableViewCellConfig)
			cell.backgroundColor = UIColor.clear
			cell.textfield?.textfield.addTarget(self, action: #selector(self.unameDidChange), for: .editingChanged)
			return cell
		case .password :
			let cell = tableView.dequeueReusableCell(withIdentifier: "passwordCell", for: indexPath) as! TextfieldTableViewCell
			self.passwordCell = cell
			cell.backgroundColor = UIColor.clear
			cell.configureCell(config: cellDetails.config as? TextfieldTableViewCellConfig)
			cell.textfield?.textfield.isSecureTextEntry = true
			cell.textfield?.textfield.addTarget(self, action: #selector(self.passwordDidChange), for: .editingChanged)
			
			let button = cell.textfield?.addRightButton(image: UIImage(named: "showPassword")!, selecteImage: UIImage(named : "hidePassword")!)
			button?.addTarget(self, action: #selector(self.showPassword), for: .touchDown)
			return cell
		case .error:
			let cell = tableView.dequeueReusableCell(withIdentifier: "error", for: indexPath) as! LabelTableViewCell
			self.errorCell = cell
			cell.backgroundColor = UIColor.clear
			cell.configureCell(config: cellDetails.config as? LabelTableViewCellConfig)
			return cell
		case .signInOption: fallthrough
		case .signUpOption: fallthrough
		case .skipOption: fallthrough
		case .signInbutton:
			let cell = tableView.dequeueReusableCell(withIdentifier: "signInCell", for: indexPath) as! ButtonTableViewCell
			
			cell.configureCell(config: cellDetails.config as? ButtonTableViewCellConfig)
			cell.button.addTarget(self, action: #selector(self.didTapedOnSignInButton(button:)), for: UIControl.Event.touchDown);
			
			return cell
		case .skipButton:
			let cell = tableView.dequeueReusableCell(withIdentifier: "skipCell", for: indexPath) as! ButtonTableViewCell
			
			cell.configureCell(config: cellDetails.config as? ButtonTableViewCellConfig)
			cell.button.addTarget(self, action: #selector(self.didTapedOnSkipButton(button:)), for: UIControl.Event.touchDown);
			
			return cell
		case .signUpbutton:
			let cell = tableView.dequeueReusableCell(withIdentifier: "signUpCell", for: indexPath) as! ButtonTableViewCell
			
			cell.configureCell(config: cellDetails.config as? ButtonTableViewCellConfig)
			cell.button.addTarget(self, action: #selector(self.didTapedOnSignUpButton(button:)), for: UIControl.Event.touchDown);
			
			return cell
		}
		
	}
	
	
	// MARK: Button Actions
	
	@objc func unameDidChange(textfield : UITextField){
		let request = Login.Validate.Request(uname: textfield.text, password: nil)
		interactor?.validate(request: request)
	}
	
	//password
	@objc func passwordDidChange(textfield : UITextField){
		let request = Login.Validate.Request(uname: nil, password: textfield.text)
		interactor?.validate(request: request)
	}
	
	@objc func showPassword(_ button : UIButton){
		button.isSelected = !button.isSelected
		passwordCell?.textfield?.textfield.isSecureTextEntry = !(passwordCell?.textfield?.textfield.isSecureTextEntry)!
	}
	
	
	@objc func didTapedOnSignInButton(button : UIButton){
		self.errorCell?.showText(str: NSAttributedString(string: ""))
		self.showHud()

		let request = Login.SignIn.Request()
		interactor?.doSignIn(request: request)
	}
	@objc func didTapedOnSignUpButton(button : UIButton){
		self.errorCell?.showText(str: NSAttributedString(string: ""))
		self.showHud()

		let request = Login.SignUp.Request()
		interactor?.doSignUp(request: request)
	}
	@objc func didTapedOnSkipButton(button : UIButton) {
		router?.routeToProducts()
	}
	

}

extension LoginView: UITextFieldDelegate{
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.view.endEditing(true)
		return false
	}
}
