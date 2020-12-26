//
//  DataStore.swift
//  ComicsCharacters
//
//  Created by vitalii on 01.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
import UIKit
protocol DataStoreProtocol: class {
	var productItems: SynchronizedArray<ProductTableModel> {get set}
	var productIds : SynchronizedArray<Int>{ get set }
	var reviewItems: SynchronizedArray<ReviewTableModel> {get set}
	var reviewIds : SynchronizedArray<Int>{ get set }
	var productImageUrls: SynchronizedArray<URL> {get set}
	
	var isLoggedIn: Bool { get set }
	var productCount:  Int { get }
	var token: String? { get set }
	var userProfile: ProfileTableModel? {get set}
	func loadProductImage(at index: Int) -> DataLoadOperation?
	func logout()
}

class DataStore: DataStoreProtocol {
	//var productCount: Int {get {return productItems.count}}
	var productCount: Int {get{return productItems.count}}
	//private var _pcount: Int = 0
	var isLoggedIn: Bool = false
	
	var token: String?
	
	var productImageUrls = SynchronizedArray<URL>()
	var productItems = SynchronizedArray<ProductTableModel>()
	
	var productIds = SynchronizedArray<Int>()
	var reviewItems = SynchronizedArray<ReviewTableModel>()
	var reviewIds = SynchronizedArray<Int>()
	var userProfile: ProfileTableModel?
	//var productCount :Int { get { return productItems.count }
	
	func logout() {
		token = nil
		isLoggedIn = false
		userProfile = nil
	}
	
	public func loadProductImage(at index: Int) -> DataLoadOperation? {
		guard let url = productImageUrls[index] else { return .none }
		return DataLoadOperation(productItems[index]?.image, url: url, row: index)
	}

	
}
