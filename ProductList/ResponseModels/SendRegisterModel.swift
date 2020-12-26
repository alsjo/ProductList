//
//  SendRegister.swift
//  ProductList
//
//  Created by vitalii on 08.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

//
//   let sendRegisterModel = try SendRegisterModel(json)

//
// To read values from URLs:
//
//   let task = URLSession.shared.sendRegisterModelTask(with: url) { sendRegisterModel, response, error in
//     if let sendRegisterModel = sendRegisterModel {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - SendRegisterModel
struct SendRegisterModel: Codable {
	let success: Bool?
	let message, token: String?
}

// MARK: SendRegisterModel convenience initializers and mutators

extension SendRegisterModel {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(SendRegisterModel.self, from: data)
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
	) -> SendRegisterModel {
		return SendRegisterModel(
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
	func sendRegisterModelTask(with url: URL, completionHandler: @escaping (SendRegisterModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: url, completionHandler: completionHandler)
	}
	
	func sendRegisterModelTask(with request: URLRequest, completionHandler: @escaping (SendRegisterModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: request, completionHandler: completionHandler)
	}
}

