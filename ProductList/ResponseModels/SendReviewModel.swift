//
//  SendReviewModel.swift
//  ProductList
//
//  Created by vitalii on 08.12.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//


//
//   let sendReviewModel = try SendReviewModel(json)

//
// To read values from URLs:
//
//   let task = URLSession.shared.sendReviewModelTask(with: url) { sendReviewModel, response, error in
//     if let sendReviewModel = sendReviewModel {
//       ...
//     }
//   }
//   task.resume()

import Foundation

// MARK: - SendReviewModel
struct SendReviewModel: Codable {
	let success: Bool
}

// MARK: SendReviewModel convenience initializers and mutators

extension SendReviewModel {
	init(data: Data) throws {
		self = try newJSONDecoder().decode(SendReviewModel.self, from: data)
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
		success: Bool? = nil
	) -> SendReviewModel {
		return SendReviewModel(
			success: success ?? self.success
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
	func sendReviewModelTask(with request: URLRequest, completionHandler: @escaping (SendReviewModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: request, completionHandler: completionHandler)
	}
	
	func sendReviewModelTask(with url: URL, completionHandler: @escaping (SendReviewModel?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.codableTask(with: url, completionHandler: completionHandler)
	}
}

