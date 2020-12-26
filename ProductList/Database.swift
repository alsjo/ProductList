//
//  CoreData.swift
//  ComicsCharacters
//
//  Created by vitalii on 15.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit
import CoreData
import Foundation

struct ProfileTableModel {
	var portrait: UIImage?
	var username: String
	var fullName: String
}

struct ProductTableModel: Hashable {
	var image: UIImage?
	var imgageUrl: String
	var title: String
	var productDescription: String
	var productId: Int
	func hash(into hasher: inout Hasher) {
		hasher.combine(productId)
	}
}

struct ReviewTableModel: Hashable {
	var text: String
	var rate: Int
	var username: String
	var fullName: String
	var productId: Int
	var reviewId: Int
	var date: Date
	func hash(into hasher: inout Hasher) {
		hasher.combine(reviewId)
	}
}

protocol DatabaseProtocol: class {
	func clearIfNeeded()
	func clearData()
	func clearProducts()
	func clearReviews()
	func getReviews(productId: Int, completion: @escaping ([ReviewTableModel]?)->())
	func saveProducts(products: [ProductTableModel])
	func saveReviews(reviews: [ReviewTableModel])
	func saveProfile(profile: ProfileTableModel)
	func getProductsCount(completion: @escaping (Int)->())
	func getProfile(username: String, completion: @escaping (ProfileTableModel?)->())
	func getProducts(completion: @escaping ([ProductTableModel]?)->())
}

class Database {
	private init() {}
	static let shared = Database()

	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "ProductList")
		
		container.loadPersistentStores(completionHandler: { (_, error) in
			guard let error = error as NSError? else { return }
			fatalError("Unresolved error: \(error), \(error.userInfo)")
		})
		
		container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
		container.viewContext.undoManager = nil
		container.viewContext.shouldDeleteInaccessibleFaults = true
		
		container.viewContext.automaticallyMergesChangesFromParent = true
		
		return container
	}()
	
	// Returns the current container view context
	var viewContext: NSManagedObjectContext {
		return persistentContainer.viewContext
	}
	
	// Creates a context for background work
	func newBackgroundContext() -> NSManagedObjectContext {
		return persistentContainer.newBackgroundContext()
	}
}

extension NSManagedObjectContext {
	
	/// Only performs a save if there are changes to commit.
	/// - Returns: `true` if a save was needed. Otherwise, `false`.
	@discardableResult public func saveIfNeeded() throws -> Bool {
		guard hasChanges else { return false }
		try save()
		return true
	}
}

extension Database: DatabaseProtocol {
	public func clearIfNeeded() {
		let eraseDatefetchRequest = NSFetchRequest<EraseDate>(entityName: "EraseDate")
		persistentContainer.performBackgroundTask { [weak self] (backgroundContext) in
			do {
				let results = try backgroundContext.fetch(eraseDatefetchRequest) 
				if results.count != 0 { // Atleast one was returned
					if let date = results[0].value(forKey: "eraseDate") as? Date {
						if Date() - date > 60*60*24 {
							results[0].setValue(Date(), forKey: "eraseDate")
							self?.clearData()
						}
					}
				}else{
					let eraseEntry = NSEntityDescription.insertNewObject(forEntityName: "EraseDate", into: backgroundContext)
					eraseEntry.setValue(Date(), forKey: "eraseDate")
				}
				do {
					try backgroundContext.saveIfNeeded()
				} catch let error as NSError {
					print("Could not save. \(error), \(error.userInfo)")
				}
			} catch let error as NSError {
				print("Erase Date Fetch Failed: \(error), \(error.userInfo)")
			}
		}
	}
	
	public func clearProducts(){
		let productsFetchRequest = NSFetchRequest<ProductsTable>(entityName: "ProductsTable")
		let productsDeleteRequest = NSBatchDeleteRequest(fetchRequest: productsFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
		persistentContainer.performBackgroundTask { (backgroundContext) in
			do {
				_ = try backgroundContext.execute(productsDeleteRequest)
			} catch let error as NSError {
				print ("Could not delete. \(error), \(error.userInfo)")
			}
		}
	}
	
	public func clearReviews(){
		let reviewsFetchRequest = NSFetchRequest<ReviewsTable>(entityName: "ReviewsTable")
		let reviewsDeleteRequest = NSBatchDeleteRequest(fetchRequest: reviewsFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
		persistentContainer.performBackgroundTask { (backgroundContext) in
			do {
				_ = try backgroundContext.execute(reviewsDeleteRequest)
			} catch let error as NSError {
				print ("Could not delete. \(error), \(error.userInfo)")
			}
		}
	}
	
	public func clearData(){
		let reviewsFetchRequest = NSFetchRequest<ReviewsTable>(entityName: "ReviewsTable")
		let reviewsDeleteRequest = NSBatchDeleteRequest(fetchRequest: reviewsFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
		let productsFetchRequest = NSFetchRequest<ProductsTable>(entityName: "ProductsTable")
		let productsDeleteRequest = NSBatchDeleteRequest(fetchRequest: productsFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
		let profileFetchRequest = NSFetchRequest<ProfileTable>(entityName: "ProfileTable")
		let profileDeleteRequest = NSBatchDeleteRequest(fetchRequest: profileFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
		let imagesFetchRequest = NSFetchRequest<ImagesTable>(entityName: "ImagesTable")
		let imagesDeleteRequest = NSBatchDeleteRequest(fetchRequest: imagesFetchRequest as! NSFetchRequest<NSFetchRequestResult>)
		let requests = [productsDeleteRequest, reviewsDeleteRequest, profileDeleteRequest, imagesDeleteRequest]
		persistentContainer.performBackgroundTask { (backgroundContext) in
			for request in requests {
				do {
					_ = try backgroundContext.execute(request)
				} catch let error as NSError {
					print ("Could not delete. \(error), \(error.userInfo)")
				}
			}
		}
	}
	
	public func saveImage(urlString: String, image: UIImage) {
		persistentContainer.performBackgroundTask { (backgroundContext) in
			
			let imageEntry = NSEntityDescription.insertNewObject(forEntityName: "ImagesTable", into: backgroundContext)
			imageEntry.setValue(urlString, forKey: "url")
			imageEntry.setValue(image.pngData(), forKey: "imageData")
			
			
			do {
				try backgroundContext.saveIfNeeded()
			} catch let error as NSError {
				print("Could not save. \(error), \(error.userInfo)")
			}
		}
	}
	
	public func getImage(urlString: String, completion: @escaping (UIImage?)->())  {
		persistentContainer.performBackgroundTask { (backgroundContext) in
			let fetchRequest = NSFetchRequest<ImagesTable>(entityName: "ImagesTable")
			fetchRequest.predicate = NSPredicate(format: "url == %@", urlString )
			fetchRequest.fetchLimit = 1
			do {
				let imagesTable = try backgroundContext.fetch(fetchRequest)
				if imagesTable.count > 0 {
					if let imageData = imagesTable[0].imageData {
						let image = UIImage(data: imageData)
						completion(image)
					}
					else{
						print ("Found empty image")
						completion(nil)
					}
				}
				else {
					//print ("no image in the db")
					completion(nil)
				}
				
				
			} catch let error as NSError {
				print ("Could not fetch image. \(error), \(error.userInfo)")
				completion(nil)
			}
		}
	}

	public func saveProducts(products: [ProductTableModel]) {
		persistentContainer.performBackgroundTask { (backgroundContext) in
			for product in products {
				let productEntry = NSEntityDescription.insertNewObject(forEntityName: "ProductsTable", into: backgroundContext)
				productEntry.setValue(product.imgageUrl, forKey: "image")
				productEntry.setValue(product.productId, forKey: "productId")
				productEntry.setValue(product.title, forKey: "title")
				productEntry.setValue(product.productDescription, forKey: "productDescription")
			}
			do {
				try backgroundContext.saveIfNeeded()
			} catch let error as NSError {
				print("Could not save. \(error), \(error.userInfo)")
			}
		}
	}

	public func saveReviews(reviews: [ReviewTableModel]) {
		persistentContainer.performBackgroundTask { (backgroundContext) in
			for review in reviews {
				let reviewEntry = NSEntityDescription.insertNewObject(forEntityName: "ReviewsTable", into: backgroundContext)
				reviewEntry.setValue(review.text, forKey: "text")
				reviewEntry.setValue(review.rate, forKey: "rate")
				reviewEntry.setValue(review.username, forKey: "username")
				reviewEntry.setValue(review.fullName, forKey: "fullName")
				reviewEntry.setValue(review.productId, forKey: "productId")
				reviewEntry.setValue(review.reviewId, forKey: "reviewId")
				reviewEntry.setValue(review.date, forKey: "date")
			}
			do {
				try backgroundContext.saveIfNeeded()
			} catch let error as NSError {
				print("Could not save. \(error), \(error.userInfo)")
			}
		}
	}
	
	
//	let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Alert")
//
//	fetchRequest.predicate = NSPredicate(format: "creationDate = %@ AND alertType = %&",
//	argumentArray: [creationDate, alertType])
//	do {
//		let results = try context.fetch(fetchRequest) as? [NSManagedObject]
//		if results?.count != 0 { // Atleast one was returned
//
//		// In my case, I only updated the first item in results
//		results[0].setValue(yourValueToBeSet, forKey: "yourCoreDataAttribute")
//		}
//	} catch {
//		print("Fetch Failed: \(error)")
//	}

	
	public func saveProfile(profile: ProfileTableModel) {
		persistentContainer.performBackgroundTask { (backgroundContext) in
			let fetchRequest = NSFetchRequest<ProfileTable>(entityName: "ProfileTable")
			fetchRequest.predicate = NSPredicate(format: "username == %@", profile.username )
			fetchRequest.fetchLimit = 1
			do {
				let profileTable = try backgroundContext.fetch(fetchRequest)
				if profileTable.count != 0 {
					if let image = profile.portrait {
						profileTable[0].setValue(image.pngData(), forKey: "portrait")
					}
					if profile.fullName != "" {
						profileTable[0].setValue(profile.fullName, forKey: "fullName")
					}
					try backgroundContext.saveIfNeeded()
				}
				else{
					let profileEntry = NSEntityDescription.insertNewObject(forEntityName: "ProfileTable", into: backgroundContext)
					profileEntry.setValue(profile.username, forKey: "username")
					profileEntry.setValue(profile.fullName, forKey: "fullName")
					if let image = profile.portrait {
						profileEntry.setValue(image.pngData(), forKey: "portrait")
					}
					
					do {
						try backgroundContext.saveIfNeeded()
					} catch let error as NSError {
						print("Could not save profile. \(error), \(error.userInfo)")
					}
				}
			} catch let error as NSError {
				print ("Could not fetch profile. \(error), \(error.userInfo)")
				
			}
			
		}
	}
	
	public func getProductsCount(completion: @escaping (Int)->())  {
		persistentContainer.performBackgroundTask { (backgroundContext) in
			let fetchRequest = NSFetchRequest<ProductsTable>(entityName: "ProductsTable")
			do {
				let count = try backgroundContext.count(for: fetchRequest)
				completion(count)
			} catch let error as NSError {
				print ("Could not fetch. \(error), \(error.userInfo)")
				completion(0)
			}
		}
	}
	
	public func getProfile(username: String, completion: @escaping (ProfileTableModel?)->())  {
		persistentContainer.performBackgroundTask { (backgroundContext) in
			let fetchRequest = NSFetchRequest<ProfileTable>(entityName: "ProfileTable")
			fetchRequest.predicate = NSPredicate(format: "username == %@", username )
			fetchRequest.fetchLimit = 1
			do {
				let profileTable = try backgroundContext.fetch(fetchRequest)
				if profileTable.count > 0 {
					
					var image: UIImage?
					if let imageData = profileTable[0].portrait {
						image = UIImage(data: imageData)
					}
						
					let profile = ProfileTableModel(portrait: image, username: profileTable[0].username ?? "", fullName: profileTable[0].fullName ?? "")
					completion(profile)
				
				}
				else {
					//print ("no image in the db")
					print ("Profile parse error")
					completion(nil)
				}
		
				
			} catch let error as NSError {
				print ("Could not fetch image. \(error), \(error.userInfo)")
				completion(nil)
			}
		}
	}
	
	public func getProducts(completion: @escaping ([ProductTableModel]?)->()) {
		persistentContainer.performBackgroundTask { (backgroundContext) in
			let fetchRequest = NSFetchRequest<ProductsTable>(entityName: "ProductsTable")
			let countFetchRequest = NSFetchRequest<ProductsTable>(entityName: "ProductsTable")
			let sort = NSSortDescriptor(key: #keyPath(ProductsTable.title), ascending: true)
			fetchRequest.sortDescriptors = [sort]
			
			do {
			
				
				let productsTable = try backgroundContext.fetch(fetchRequest)
				if productsTable.count == 0 { completion(nil); return}
				var products = [ProductTableModel]()
				
				for product in productsTable {
					let title = product.title ?? ""
					let description = product.productDescription ?? ""
					
					let productModel = ProductTableModel(imgageUrl: product.image ?? "", title: title, productDescription: description, productId: Int(product.productId))
						products.append(productModel)
					
				}
				completion(products)
			} catch let error as NSError {
				print ("Could not fetch products. \(error), \(error.userInfo)")
				completion(nil)
			}
			
		}
		
	}

	public func getReviews(productId: Int, completion: @escaping ([ReviewTableModel]?)->()) {
		persistentContainer.performBackgroundTask { (backgroundContext) in
			let fetchRequest = NSFetchRequest<ReviewsTable>(entityName: "ReviewsTable")
			let countFetchRequest = NSFetchRequest<ReviewsTable>(entityName: "ReviewsTable")
			let sort = NSSortDescriptor(key: #keyPath(ReviewsTable.date), ascending: true)
			fetchRequest.predicate = NSPredicate(format: "productId == %d", productId )
			fetchRequest.sortDescriptors = [sort]

			do {
				
				let reviewsTable = try backgroundContext.fetch(fetchRequest)
				if reviewsTable.count == 0 { completion(nil); return}

					var reviews = [ReviewTableModel]()
					
					for review in reviewsTable {
					
						let rw = ReviewTableModel(text: review.text ?? "",
													  rate: Int(review.rate),
													  username: review.username ?? "",
													  fullName: review.fullName ?? "",
													  productId: Int(review.productId),
													  reviewId: Int(review.reviewId),
													  date: review.date ?? Date())
						reviews.append(rw)
						
						
					}
				
					completion(reviews)

			} catch let error as NSError {
				print ("Could not fetch characters. \(error), \(error.userInfo)")
				completion(nil)
			}
			
		}
		
	}
}

