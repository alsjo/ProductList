//
//  DataProvider.swift
//  ComicsCharacters
//
//  Created by vitalii on 20.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
import Reachability
import UIKit
protocol DataProviderProtocol: class {
	static var shared: DataProviderProtocol {get}
	var isReachable: Bool { get }
	var productsLoading: Bool { get }
	var reviewsLoading: Bool { get }
	var loginLoading: Bool { get }
	var registerLoading: Bool { get }
	var sendReviewLoading: Bool { get }
	var dataStore: DataStoreProtocol { get }
	var database: DatabaseProtocol { get }
	
	func setProfilePortrait(image: UIImage)
	func setProfileName(name: String)
	func getReviews(productId: Int, completion: @escaping (Bool)->())
	func getProducts(completion: @escaping (Bool)->())
	func sendRegister(uname: String, pw: String, completion: @escaping (Bool, String?)->())
	func sendLogin(uname: String, pw: String, completion: @escaping (Bool, String?)->())
	func sendReview(productId: Int, rate: Int, text: String, completion: @escaping (Bool)->())
}

class DataProvider: DataProviderProtocol {
	static var shared: DataProviderProtocol = DataProvider()
	
	//static var shared: DataProviderProtocol
	
	var productsLoading = false
	var reviewsLoading = false
	var loginLoading = false
	var registerLoading = false
	var sendReviewLoading = false
	var isReachable = false
	
	//static var shared = DataProvider()
	let dataStore: DataStoreProtocol = DataStore()
	let api: ApiProtocol = Api()
	let database: DatabaseProtocol = Database.shared
	
	//declare this property where it won't go out of scope relative to your listener
	let reachability = try! Reachability()
	
	init() {
		reachability.whenReachable = { [weak self] reachability in
			self?.isReachable = true
			if reachability.connection == .wifi {
				print("Reachable via WiFi")
			} else {
				print("Reachable via Cellular")
			}
		}
		reachability.whenUnreachable = { [weak self] _ in
			self?.isReachable = false
			print("Not reachable")
		}
		
		do {
			try reachability.startNotifier()
			print("reachability notifier started")
		} catch {
			print("Unable to start notifier")
		}
	}
	
	
	deinit {
		reachability.stopNotifier()
		print("reachability notifier stopped")
	}
	
	func setProfilePortrait(image: UIImage) {
		if var profile = dataStore.userProfile {
			profile.portrait = image
			dataStore.userProfile = profile
			database.saveProfile(profile: profile)
		}
	}
	
	func setProfileName(name: String) {
		//guard let profile = dataStore.userProfile else { return}
		if var profile = dataStore.userProfile {
			profile.fullName = name
			dataStore.userProfile = profile
			database.saveProfile(profile: profile)
		}
	}
	
	func getUserProfile() -> ProfileTableModel? {
		if let user =  dataStore.userProfile {
			return user
		}
		return nil
	}

	func getReviews(productId: Int, completion: @escaping (Bool) -> ()) {
		if reviewsLoading == false {
			reviewsLoading = true
			
			if isReachable {
				print("getReviews api request")
				api.getReviews(productId: productId, token: self.dataStore.token) {[weak self] (reviewsModels, data, response, error) in
					self?.reviewsLoading = false
					
					guard let reviewsModels = reviewsModels else { completion(false); return}
					print("Reviews received from api")
					var reviewTableModels = [ReviewTableModel]()
					let formatter = DateFormatter()
					formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"
					
					for rm in reviewsModels {
						let date = formatter.date(from: rm.createdAt) ?? Date()
						var name = rm.createdBy.firstName + " " + rm.createdBy.lastName
						if rm.createdBy.firstName == "" && rm.createdBy.lastName == "" {
							name = rm.createdBy.username
						}
						reviewTableModels.append(ReviewTableModel(text: rm.text,
																  rate: rm.rate,
																  username: rm.createdBy.username,
																  fullName: name,
																  productId: rm.product,
																  reviewId: rm.id,
																  date: date))
					}
					self?.dataStore.reviewItems.removeAll()
					self?.dataStore.reviewItems.append( reviewTableModels)
					self?.database.clearReviews(for: productId)
					self?.database.saveReviews(reviews: reviewTableModels)
					completion(true)
				
					
				}
			}
			else {
				print("loading Reviews from database")
				database.getReviews(productId: productId) {[weak self] (reviews) in
					self?.reviewsLoading = false
					guard let reviews = reviews else { completion(false); return}
					print("Reviews receiverd from database")
					if  reviews.count > 0 {
						self?.dataStore.reviewItems.removeAll()
						self?.dataStore.reviewItems.append(reviews)
						completion(true)
					}
					else{
						completion(false)
					}
				}
			}
		
		}
	}
	
	func getProducts(completion: @escaping (Bool) -> ()) {
		if productsLoading == false {
			productsLoading = true
			
			if isReachable {
				print("getProducts api request")
				api.getProducts(token: self.dataStore.token) {[weak self] (products, data, response, error) in
					self?.productsLoading = false
					
					guard let products = products else { completion(false); return}
					print("Products received from api")
					var productTableModels = [ProductTableModel]()
					let formatter = DateFormatter()
					formatter.dateFormat = "YYYY-MM-DD'T'HH:mm:ss.SSS'Z'"
					self?.dataStore.productImageUrls.removeAll()
					for p in products {
						productTableModels.append(ProductTableModel(imgageUrl: p.img,
																	title: p.title,
																	productDescription: p.text,
																	productId: p.id))
						if let imageUrl = URL(string: ("\(self?.api.imgUrl ?? "")\( p.img)")){
							self?.dataStore.productImageUrls.append(imageUrl)
						}
					}
					self?.dataStore.productItems.removeAll()
					self?.dataStore.productItems.append( productTableModels)
					self?.database.clearProducts()
					self?.database.saveProducts(products: productTableModels)
					completion(true)
					
					
				}
			}
			else {
				print("Loading Products from database")
				database.getProducts() {[weak self] (products) in
					self?.productsLoading = false
					guard let products = products else { completion(false); return}
					print("Products received from database")
					if  products.count > 0 {
						self?.dataStore.productItems.removeAll()
						self?.dataStore.productImageUrls.removeAll()
						self?.dataStore.productItems.append(products)
						for p in products{
							if let imageUrl = URL(string: ("\(self?.api.imgUrl ?? "")\( p.imgageUrl)")){
								self?.dataStore.productImageUrls.append(imageUrl)
							}
						}
						completion(true)
					}
					else{
						completion(false)
					}
				}
			}
			
		}
	}
	
	func sendRegister(uname: String, pw: String, completion: @escaping (Bool, String?) -> ()) {
		if registerLoading == false {
			self.registerLoading = true
			print("sendRegister api request")
			api.sendRegister(uname: uname, pw: pw) {[weak self] (registerModel, data, response, error) in
				self?.registerLoading = false
				guard let registerModel = registerModel else { completion(false, ""); return}
				print("Register response received from api")
				if registerModel.success == true {
					print("SignUp successfull")
					self?.dataStore.token = registerModel.token
					self?.dataStore.isLoggedIn = true
					completion(true, "")
					let profile = ProfileTableModel(portrait: nil, username: uname, fullName: "")
					self?.database.saveProfile(profile: profile)
					self?.dataStore.userProfile = profile
				}
				else{
					print("SignUp failed")
					completion(false, registerModel.message)
				}
				
			}
		}
	}
	
	func sendLogin(uname: String, pw: String, completion: @escaping (Bool, String?) -> ()) {
		if loginLoading == false {
			self.loginLoading = true
			print("sendLogin api request")
			api.sendLogin(uname: uname, pw: pw) {[weak self] (loginModel, data, response, error) in
				self?.loginLoading = false
				guard let loginModel = loginModel else { completion(false, error?.localizedDescription); return}
				print("Login response received from api")
				if loginModel.success == true {
					print("Login successfull")
					self?.dataStore.token = loginModel.token
					self?.dataStore.isLoggedIn = true
					completion(true, nil)
					self?.database.getProfile(username: uname, completion: { (profile) in
						if let profile = profile {
							self?.dataStore.userProfile = profile
						} else {
							let newProfile = ProfileTableModel(portrait: nil, username: uname, fullName: "")
							self?.database.saveProfile(profile: newProfile)
							self?.dataStore.userProfile = newProfile
						}
					})
				}
				else{
					
					print("SignUp failed")
					completion(false, loginModel.message)
					
				}
				
			}
		}
	}
	
	func sendReview(productId: Int, rate: Int, text: String, completion: @escaping (Bool) -> ()) {
		guard let token = self.dataStore.token else { print("no token!"); completion(false); return;}
		if sendReviewLoading == false {
			sendReviewLoading = true
			print("sendReview api request")
			api.sendReview(productId: productId, rate: rate, text: text, token: token) {[weak self] (reviewModel, data, response, error) in
				self?.sendReviewLoading = false
				guard let reviewModel = reviewModel else { completion(false); return}
				print("sendReview response received from api")
				if reviewModel.success == true {
					completion(true)
				}
				else{
					completion(false)
				}
				
			}
		}
	}
}
