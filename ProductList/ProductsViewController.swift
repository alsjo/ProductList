//
//  ProductsViewController.swift
//  ProductList
//
//  Created by vitalii on 04.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit
import JGProgressHUD
class ProductsViewController: UIViewController {
	@IBOutlet weak var tableView: UITableView!
	let dataProvider: DataProviderProtocol = DataProvider.shared
	let productImageLoadingQueue = OperationQueue()
	var productImageLoadingOperations = ThreadSafeDictionary<IndexPath, DataLoadOperation>(queueLabel: "com.vl.productImages")
	let hud = JGProgressHUD()
	//var productStubItems = SynchronizedArray<Int>()
	override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationItem.title = "Products"
		if dataProvider.dataStore.isLoggedIn {
			setupProfileButton()
		}
		self.dataProvider.database.clearIfNeeded()
		//self.productStubItems.append([Int](repeating: 0, count: infiniteNumber))
		hud.show(in: self.view)
		self.dataProvider.getProducts { [weak self] (success) in
			DispatchQueue.main.async { [weak self] in
				self?.hud.dismiss()
				self?.setupTableView()
				self?.tableView.reloadData()
			}
		}
		
        // Do any additional setup after loading the view.
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if dataProvider.dataStore.isLoggedIn {
			showProfileButton()
			self.navigationItem.setHidesBackButton(true, animated: false)
		}
		else{
			hideProfileButton()
			self.navigationItem.setHidesBackButton(false, animated: false)
		}
	}
	
	func hideProfileButton(){
		if let btn = self.navigationItem.rightBarButtonItem {
			btn.isEnabled = false
			btn.setBackgroundImage(nil, for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
		}

	}
	
	func showProfileButton(){
		if let btn = self.navigationItem.rightBarButtonItem {
			btn.isEnabled = true
			let iconImage = UIImage(systemName: "person.circle")
			btn.setBackgroundImage(iconImage, for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
		}
		
	}
	
	func setupProfileButton(){
		
		let iconImage = UIImage(systemName: "person.circle")
		let button =  UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(editProfileClick))
		button.setBackgroundImage(iconImage, for: UIControl.State.normal, barMetrics: UIBarMetrics.default)
		button.tintColor = view.tintColor
		self.navigationItem.rightBarButtonItem = button
		
	}
	
	@objc func editProfileClick(){
		//print("edit Profile")
		goToProfile()
	}
	

	
	func goToProfile(){
		let sampleStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = sampleStoryBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
		DispatchQueue.main.async { [weak self] in
			self?.navigationController?.pushViewController(vc, animated: true)
		}
	}
	
	func goToReview(productId: Int) {
		let sampleStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = sampleStoryBoard.instantiateViewController(withIdentifier: "CommentsViewController") as! CommentsViewController
		vc.productIndex = productId
		DispatchQueue.main.async { [weak self] in
			self?.navigationController?.pushViewController(vc, animated: true)
		}
	}

	func setupTableView(){
		tableView.dataSource = self
		tableView.delegate = self
		tableView.alwaysBounceVertical = true
		tableView.prefetchDataSource = self
		tableView.estimatedRowHeight = 200
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
extension ProductsViewController: UITableViewDelegate {
	//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		if let product = self.dataProvider.dataStore.productItems[indexPath.row] {
			
			goToReview(productId: indexPath.row)
			
		}
	}
}

extension ProductsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return  self.dataProvider.dataStore.productCount
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell",
												 for: indexPath as IndexPath) as! ProductCell
		
		if let title = self.dataProvider.dataStore.productItems[indexPath.row]?.title {
			cell.updateTitle(row: indexPath.row, section: indexPath.row, title: title, animated: false)
		}
		
		if let description = self.dataProvider.dataStore.productItems[indexPath.row]?.productDescription {
			cell.updateDescription(description: description, animated: false)
		}
		
		if let image = self.dataProvider.dataStore.productItems[indexPath.row]?.image {
			
			cell.updateImage(image: image, animated: false, row: indexPath.row)
		}
		return cell
	}
	
	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		guard let cell = cell as? ProductCell else { return }
		let updateCellClosure: (UIImage?, Int, Int) -> () = { [weak self] image, row, section in
			guard let self = self else {
				return
			}
			
			if let image = image {
				
				// MARK: TODO - view should not write to the data store
				
				if(indexPath.row == row)
				{
					self.dataProvider.dataStore.productItems[indexPath.row]?.image = image//view should not write to the data store
					cell.updateImage(image: image, animated: true, row: indexPath.row)
					cell.updateTitle(row: row, section: section, title: nil)
				}
				
				self.productImageLoadingOperations.removeValue(forKey: indexPath)
			}
			
			
		}
		
		if let image = self.dataProvider.dataStore.productItems[indexPath.row]?.image {
			cell.updateImage(image: image, animated: false, row: indexPath.row)
		}
		else{
			// Try to find an existing data loader
			if let dataLoader = productImageLoadingOperations[indexPath] {
				dataLoader.loadingCompleteHandler = updateCellClosure
			} else {
				// Need to create a data loaded for this index path
				if let dataLoader = self.dataProvider.dataStore.loadProductImage(at: indexPath.row){
					// Provide the completion closure, and kick off the loading operation
					dataLoader.loadingCompleteHandler = updateCellClosure
					productImageLoadingQueue.addOperation(dataLoader)
					productImageLoadingOperations[indexPath] = dataLoader
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		
	}
	
}

extension ProductsViewController: UITableViewDataSourcePrefetching {
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			
				
			if (self.dataProvider.dataStore.productItems[indexPath.row]?.image) != nil {
					
				}else {
					
					if let _ = productImageLoadingOperations[indexPath] {
						continue
					}
				if let dataLoader = self.dataProvider.dataStore.loadProductImage(at: indexPath.row) {
						let updateImageClosure: (UIImage?, Int, Int) -> () = { [weak self] image, row, section in
							guard let self = self else {
								return
							}
							if let image = image {
								if(indexPath.row == row)
								{
									self.dataProvider.dataStore.productItems[indexPath.row]?.image = image
								}
								else {
									print("prefetch fuck up prevented")
								}
								self.productImageLoadingOperations.removeValue(forKey: indexPath)
							}
							
						}
						dataLoader.loadingCompleteHandler = updateImageClosure
						productImageLoadingQueue.addOperation(dataLoader)
						
						productImageLoadingOperations[indexPath] = dataLoader
					}
				}
		}
		
	}
	func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			
				if let dataLoader = productImageLoadingOperations[indexPath] {
					dataLoader.cancel()
					productImageLoadingOperations.removeValue(forKey: indexPath)
				}
		}
		
	}
}
