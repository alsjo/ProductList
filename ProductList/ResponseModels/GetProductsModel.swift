//
//  GetProducts.swift
//  ProductList
//
//  Created by vitalii on 08.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

//
//   let getProductsModel = try GetProductsModel(json)

//
// To read values from URLs:
//
//   let task = URLSession.shared.getProductsModelElementTask(with: url) { getProductsModelElement, response, error in
//     if let getProductsModelElement = getProductsModelElement {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - GetProductsModelElement
struct GetProductsModelElement: Codable {
	let id: Int
	let title, img, text: String
}

// MARK: GetProductsModelElement convenience initializers and mutators

extension GetProductsModelElement {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(GetProductsModelElement.self, from: data)
	}
	
	init(_ json: String, using encoding: String.Encoding = .utf8) throws {
		guard let data = json.data(using: encoding) else {
			throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
		}
		try self.init(data: data)
	}
	
	init(fromURL url: URL) throws {
		try self.init(data: try Data(contentsOf: url))
	}
	
	func with(
		id: Int? = nil,
		title: String? = nil,
		img: String? = nil,
		text: String? = nil
	) -> GetProductsModelElement {
		return GetProductsModelElement(
			id: id ?? self.id,
			title: title ?? self.title,
			img: img ?? self.img,
			text: text ?? self.text
		)
	}
	
	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}
	
	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

typealias GetProductsModel = [GetProductsModelElement]

extension Array where Element == GetProductsModel.Element {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(GetProductsModel.self, from: data)
	}
	
	init(_ json: String, using encoding: String.Encoding = .utf8) throws {
		guard let data = json.data(using: encoding) else {
			throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
		}
		try self.init(data: data)
	}
	
	init(fromURL url: URL) throws {
		try self.init(data: try Data(contentsOf: url))
	}
	
	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}
	
	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

// MARK: - URLSession response handlers

extension URLSession {

	func getProductsModelTask(with request: URLRequest, completionHandler: @escaping (GetProductsModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: request, completionHandler: completionHandler)
	}
	func getProductsModelTask(with url: URL, completionHandler: @escaping (GetProductsModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: url, completionHandler: completionHandler)
	}
}
