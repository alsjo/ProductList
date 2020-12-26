//
//  GetReviews.swift
//  ProductList
//
//  Created by vitalii on 08.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

//
//   let getReviewsModel = try GetReviewsModel(json)

//
// To read values from URLs:
//
//   let task = URLSession.shared.getReviewsModelElementTask(with: url) { getReviewsModelElement, response, error in
//     if let getReviewsModelElement = getReviewsModelElement {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - GetReviewsModelElement
struct GetReviewsModelElement: Codable {
	let id, product, rate: Int
	let text: String
	let createdBy: CreatedBy
	let createdAt: String
	
	enum CodingKeys: String, CodingKey {
		case id, product, rate, text
		case createdBy = "created_by"
		case createdAt = "created_at"
	}
}

// MARK: GetReviewsModelElement convenience initializers and mutators

extension GetReviewsModelElement {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(GetReviewsModelElement.self, from: data)
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
		product: Int? = nil,
		rate: Int? = nil,
		text: String? = nil,
		createdBy: CreatedBy? = nil,
		createdAt: String? = nil
	) -> GetReviewsModelElement {
		return GetReviewsModelElement(
			id: id ?? self.id,
			product: product ?? self.product,
			rate: rate ?? self.rate,
			text: text ?? self.text,
			createdBy: createdBy ?? self.createdBy,
			createdAt: createdAt ?? self.createdAt
		)
	}
	
	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}
	
	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

//
// To read values from URLs:
//
//   let task = URLSession.shared.createdByTask(with: url) { createdBy, response, error in
//     if let createdBy = createdBy {
//       ...
//     }
//   }
//   task.resume()

// MARK: - CreatedBy
struct CreatedBy: Codable {
	let id: Int
	let username, firstName, lastName, email: String
	
	enum CodingKeys: String, CodingKey {
		case id, username
		case firstName = "first_name"
		case lastName = "last_name"
		case email
	}
}

// MARK: CreatedBy convenience initializers and mutators

extension CreatedBy {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(CreatedBy.self, from: data)
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
		username: String? = nil,
		firstName: String? = nil,
		lastName: String? = nil,
		email: String? = nil
	) -> CreatedBy {
		return CreatedBy(
			id: id ?? self.id,
			username: username ?? self.username,
			firstName: firstName ?? self.firstName,
			lastName: lastName ?? self.lastName,
			email: email ?? self.email
		)
	}
	
	func jsonData() throws -> Data {
		return try newJSONEncoder().encode(self)
	}
	
	func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
		return String(data: try self.jsonData(), encoding: encoding)
	}
}

typealias GetReviewsModel = [GetReviewsModelElement]

extension Array where Element == GetReviewsModel.Element {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(GetReviewsModel.self, from: data)
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

	func getReviewsModelTask(with request: URLRequest, completionHandler: @escaping (GetReviewsModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: request, completionHandler: completionHandler)
	}
	func getReviewsModelTask(with url: URL, completionHandler: @escaping (GetReviewsModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: url, completionHandler: completionHandler)
	}
}

