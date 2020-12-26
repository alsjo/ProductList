//
//  MarvelApi.swift
//  ComicsCharacters
//
//  Created by vitalii on 18.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
protocol ApiProtocol: class {
	var imgUrl: String {get}
	func getReviews(productId: Int, token: String?, completion: @escaping (GetReviewsModel?, Data?, URLResponse?, Error?)->())
	func getProducts(token: String?, completion: @escaping (GetProductsModel?, Data?, URLResponse?, Error?)->())
	func sendRegister(uname: String, pw: String, completion: @escaping (SendRegisterModel?, Data?, URLResponse?, Error?)->())
	func sendLogin(uname: String, pw: String, completion: @escaping (SendLoginModel?, Data?, URLResponse?, Error?)->())
	func sendReview(productId: Int, rate: Int, text: String, token: String, completion: @escaping (SendReviewModel?, Data?, URLResponse?, Error?)->())
}

class Api: ApiProtocol {
	private var apiUrl = "https://smktesting.herokuapp.com/api/"
	var imgUrl = "https://smktesting.herokuapp.com/static/"
	private var loginTask: URLSessionDataTask?
	private var registerTask: URLSessionDataTask?
	private var reviewsTask: URLSessionDataTask?
	private var productsTask: URLSessionDataTask?
	private var sendReviewTask: URLSessionDataTask?
	
	
	private var _isLoginRequest = false
	private var _isRegisterRequest = false
	private var _isSendReviewRequest = false
	private var _isReviewsRequest = false
	private var _isProductsRequest = false
	fileprivate let lqueue = DispatchQueue(label: "com.vl.isLoginRequest", attributes: .concurrent)
	fileprivate let rqueue = DispatchQueue(label: "com.vl.isRegisterRequest", attributes: .concurrent)
	fileprivate let srqueue = DispatchQueue(label: "com.vl.isSendReviewRequest", attributes: .concurrent)
	fileprivate let rwqueue = DispatchQueue(label: "com.vl.isReviewsRequest", attributes: .concurrent)
	fileprivate let pqueue = DispatchQueue(label: "com.vl.isProductsRequest", attributes: .concurrent)
	
	private var isLoginRequest: Bool {
		get {
			var result = false
			lqueue.sync { result = self._isLoginRequest }
			return result
			
		}
		set (value) {
			lqueue.async(flags: .barrier) {
				self._isLoginRequest = value
			}
			
		}
	}
	
	
	private var isRegisterRequest: Bool {
		get {
			var result = false
			rqueue.sync { result = self._isRegisterRequest }
			return result
			
		}
		set (value) {
			rqueue.async(flags: .barrier) {
				self._isRegisterRequest = value
			}
			
		}
	}
	
	
	private var isSendReviewRequest: Bool {
		get {
			var result = false
			srqueue.sync { result = self._isSendReviewRequest }
			return result
			
		}
		set (value) {
			srqueue.async(flags: .barrier) {
				self._isSendReviewRequest = value
			}
			
		}
	}
	
	
	private var isReviewsRequest: Bool {
		get {
			var result = false
			rwqueue.sync { result = self._isReviewsRequest }
			return result
			
		}
		set (value) {
			rwqueue.async(flags: .barrier) {
				self._isReviewsRequest = value
			}
			
		}
	}
	
	
	private var isProductsRequest: Bool {
		get {
			var result = false
			pqueue.sync { result = self._isProductsRequest }
			return result
			
		}
		set (value) {
			pqueue.async(flags: .barrier) {
				self._isProductsRequest = value
			}
			
		}
	}
	
	

	
	func getReviews(productId: Int, token: String?, completion: @escaping (GetReviewsModel?, Data?, URLResponse?, Error?)->())
	{
		let reqUrlString = self.getProductReviewsUrl(productId: productId)
		
		// Setup the request with URL
		let url = URL(string: reqUrlString)
		var urlRequest = URLRequest(url: url!)
		
		
		// Set the httpMethod and assign httpBody
		urlRequest.httpMethod = "GET"
		
		if let token = token {
			urlRequest.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
		}
		
		if isReviewsRequest == true { reviewsTask?.cancel() }
		isReviewsRequest = true
		// Create dataTask
		reviewsTask = URLSession.shared.getReviewsModelTask(with: urlRequest, completionHandler: {[weak self]  (getReviewsModel, data, response, error) in
			self?.isReviewsRequest = false
			if let getReviewsModel = getReviewsModel {
				completion(getReviewsModel, data, response, error)
			} else {
				print("failed to parse reviews response")
				completion(nil, data, response, error)
			}
			
		})
		reviewsTask?.resume()
	}
	
	func getProducts(token: String?, completion: @escaping (GetProductsModel?, Data?, URLResponse?, Error?)->())
	{
		let reqUrlString = self.getProductsUrl()
		
		// Setup the request with URL
		let url = URL(string: reqUrlString)
		var urlRequest = URLRequest(url: url!)
		
		
		// Set the httpMethod and assign httpBody
		urlRequest.httpMethod = "GET"
		
		if let token = token {
			urlRequest.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
		}
		
		if isProductsRequest == true { productsTask?.cancel() }
		isProductsRequest = true
		// Create dataTask
		productsTask = URLSession.shared.getProductsModelTask(with: urlRequest, completionHandler: {[weak self]  (getProductsModel, data, response, error) in
			self?.isProductsRequest = false
			if let getProductsModel = getProductsModel {
				completion(getProductsModel, data, response, error)
			} else {
				print("failed to parse products response")
				completion(nil, data, response, error)
			}
			
		})
		productsTask?.resume()
	}
	
	func sendRegister(uname: String, pw: String, completion: @escaping (SendRegisterModel?, Data?, URLResponse?, Error?)->())
	{
		let reqUrlString = self.getRegisterUrl()
		
		// Setup the request with URL
		let url = URL(string: reqUrlString)
		var urlRequest = URLRequest(url: url!)
	
		// Convert POST string parameters to data using UTF8 Encoding
		let postParams = self.postRegisterParams(uname: uname, pwd: pw)
		let postData = postParams.data(using: .utf8)
	
		// Set the httpMethod and assign httpBody
		urlRequest.httpMethod = "POST"
		urlRequest.httpBody = postData
		
		if isRegisterRequest == true { registerTask?.cancel() }
		isRegisterRequest = true
		// Create dataTask
		registerTask = URLSession.shared.sendRegisterModelTask(with: urlRequest, completionHandler: {[weak self]  (sendRegisterModel, data, response, error) in
			self?.isRegisterRequest = false
			if let sendRegisterModel = sendRegisterModel {
				completion(sendRegisterModel, data, response, error)
			} else {
				print("failed to parse register response")
				completion(nil, data, response, error)
			}
			
		})
		registerTask?.resume()
	
	}
	
	func sendLogin(uname: String, pw: String, completion: @escaping (SendLoginModel?, Data?, URLResponse?, Error?)->())
	{
		let reqUrlString = self.getLoginUrl()
		
		// Setup the request with URL
		let url = URL(string: reqUrlString)
		var urlRequest = URLRequest(url: url!)
		
		// Convert POST string parameters to data using UTF8 Encoding
		let postParams = self.postLoginParams(uname: uname, pwd: pw)
		let postData = postParams.data(using: .utf8)
		
		// Set the httpMethod and assign httpBody
		urlRequest.httpMethod = "POST"
		urlRequest.httpBody = postData
		
		if isLoginRequest == true { loginTask?.cancel() }
		isLoginRequest = true
		// Create dataTask
		loginTask = URLSession.shared.sendLoginModelTask(with: urlRequest, completionHandler: {[weak self]  (sendLoginModel, data, response, error) in
			self?.isLoginRequest = false
			if let sendLoginModel = sendLoginModel {
				completion(sendLoginModel, data, response, error)
			} else {
				print("failed to parse login response")
				completion(nil, data, response, error)
			}
			
		})
		loginTask?.resume()
		
	}
	
	func sendReview(productId: Int, rate: Int, text: String, token: String, completion: @escaping (SendReviewModel?, Data?, URLResponse?, Error?)->())
	{
		let reqUrlString = self.getProductReviewsUrl(productId: productId)
		
		// Setup the request with URL
		let url = URL(string: reqUrlString)
		var urlRequest = URLRequest(url: url!)
		
		// Convert POST string parameters to data using UTF8 Encoding
		let postParams = self.postReviewParams(rate: rate, text: text)
		let postData = postParams.data(using: .utf8)
		
		// Set the httpMethod and assign httpBody
		urlRequest.httpMethod = "POST"
		urlRequest.httpBody = postData
		urlRequest.setValue("Token \(token)", forHTTPHeaderField: "Authorization")
		if isSendReviewRequest == true { sendReviewTask?.cancel() }
		isLoginRequest = true
		// Create dataTask
		sendReviewTask = URLSession.shared.sendReviewModelTask(with: urlRequest, completionHandler: {[weak self]  (sendReviewModel, data, response, error) in
			self?.isSendReviewRequest = false
			if let sendReviewModel = sendReviewModel {
				completion(sendReviewModel, data, response, error)
			} else {
				print("failed to parse send review response")
				completion(nil, data, response, error)
			}
			
		})
		sendReviewTask?.resume()
		
	}
	///api/reviews/<product_id>/
	private func postReviewParams(rate: Int, text: String) -> String {
		let escapedString = text.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
		return "rate=\(rate)&text=\(escapedString ?? "")"
	}
	
	private func postRegisterParams(uname: String, pwd: String) -> String {
		return postLoginParams(uname: uname, pwd: pwd)
	}

	private func postLoginParams(uname: String, pwd: String) -> String {
		let escapedUname = uname.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
		let escapedPwd = pwd.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)
		return "username=\(escapedUname ?? "")&password=\(escapedPwd ?? "")"
	}
	
	private func getRegisterUrl() -> String {
		return apiUrl + "register/"
	}
	
	private func getLoginUrl() -> String {
		return apiUrl + "login/"
	}
	
	private func getProductsUrl() -> String {
		return apiUrl + "products/"
	}
	
	private func getProductReviewsUrl(productId: Int) -> String {
		return apiUrl + "reviews/\(productId)"
	}
	
	private func limitAndOffsetParameters(offset: Int, limit: Int) -> String {
		return "limit=\(limit)&offset=\(offset)"
	}
}
