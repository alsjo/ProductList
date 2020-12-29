//
//  CommentsViewController.swift
//  ProductList
//
//  Created by vitalii on 04.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit
import JGProgressHUD
class CommentsViewController: UIViewController {

	@IBOutlet weak var CommentsTable: UITableView!
	@IBOutlet weak var btAddComment: UIButton!
	@IBOutlet weak var tableView: UITableView!
	let dataProvider: DataProviderProtocol = DataProvider.shared
	let hud = JGProgressHUD()
	var productStubItems = SynchronizedArray<Int>()
	public var productIndex: Int!
	var productId: Int?
	override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.title = "Reviews"
		if let productId = self.dataProvider.dataStore.productItems[productIndex]?.productId {
			self.productId = productId
			hud.show(in: self.view)
			self.dataProvider.getReviews(productId: productId) { [weak self] (success) in
				DispatchQueue.main.async { [weak self] in
					self?.hud.dismiss()
					self?.setupTableView()
					self?.tableView.reloadData()
				}
			}
		}
        // Do any additional setup after loading the view.
    }
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.btAddComment.isEnabled = self.dataProvider.dataStore.isLoggedIn
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		self.dataProvider.dataStore.reviewItems.removeAll()
	}

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

	@IBAction func btAddCommentClick(_ sender: Any) {
		goToReviewInput()
	}
	
	func goToReviewInput(){
		if !self.dataProvider.dataStore.isLoggedIn {
			//not logged in
			print("not logged in")
		}
		else {
			// Register Nib
			let vc = CommentInputViewController(nibName: "CommentInput", bundle: nil)
			vc.onSubmit = { [weak self] rating, text in
				if let productId = self?.productId
				{
					self?.dataProvider.sendReview(productId: productId, rate: rating, text: text, completion: { (success) in
						if success {
							print("review has been submitted")
							self?.dataProvider.getReviews(productId: productId, completion: { (success) in
								if success {
									print("reviews have been updated")
									DispatchQueue.main.async { [weak self] in
										self?.tableView.reloadData()
									}
								}
								else{
									print("Unable to update reviews :(")
								}
							})
						} else
						{
							print("review has not been submitted :(")
						}
					})
				}
			}
			// Present View "Modally"
			DispatchQueue.main.async { [weak self] in
				self?.present(vc, animated: true, completion: nil)
			}
		}

	}
	
	func setupTableView(){
		tableView.dataSource = self
		tableView.delegate = self
		tableView.alwaysBounceVertical = true
		tableView.rowHeight = UITableView.automaticDimension
		tableView.estimatedRowHeight = 300
	}
}

extension CommentsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
	}
}

extension CommentsViewController: UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return  self.dataProvider.dataStore.reviewItems.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell",
												 for: indexPath as IndexPath) as! CommentCell
		
		if let name = self.dataProvider.dataStore.reviewItems[indexPath.row]?.fullName {
			cell.updateName(name: name, animated: false)
		}
		
		if let text = self.dataProvider.dataStore.reviewItems[indexPath.row]?.text {
			cell.updateText(text:text, animated: false)
		}
		
		if let rating = self.dataProvider.dataStore.reviewItems[indexPath.row]?.rate {
			
			cell.updateRating(rating: rating, animated: false)
		}
		
		if let username = self.dataProvider.dataStore.reviewItems[indexPath.row]?.username  {
			if username == self.dataProvider.dataStore.userProfile?.username {
				if let image = self.dataProvider.dataStore.userProfile?.portrait {
					cell.updateImage(image: image, animated: false, row: indexPath.row)
				}
			}
		}
		return cell
	}
	
	
	
}

