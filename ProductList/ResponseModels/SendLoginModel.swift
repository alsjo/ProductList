//
//  SendLoginModel.swift
//  ProductList
//
//  Created by vitalii on 08.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation

// MARK: - SendLoginModel
struct SendLoginModel: Codable {
	let success: Bool?
	let message, token: String?
}

// MARK: SendLoginModel convenience initializers and mutators

extension SendLoginModel {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(SendLoginModel.self, from: data)
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
		success: Bool?? = nil,
		message: String?? = nil,
		token: String?? = nil
	) -> SendLoginModel {
		return SendLoginModel(
			success: success ?? self.success,
			message: message ?? self.message,
			token: token ?? self.token
		)
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
	func sendLoginModelTask(with url: URL, completionHandler: @escaping (SendLoginModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: url, completionHandler: completionHandler)
	}
	
	func sendLoginModelTask(with request: URLRequest, completionHandler: @escaping (SendLoginModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: request, completionHandler: completionHandler)
	}
}

