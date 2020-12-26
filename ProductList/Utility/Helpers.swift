//
//  Helpers.swift
//  ComicsCharacters
//
//  Created by vitalii on 04.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
import UIKit
import CryptoKit


public let blankFace = UIImage(named: "blankFace")!
public let infiniteNumber = 10000

public func MD5(_ string: String) -> String {
	let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
	
	return digest.map {
		String(format: "%02hhx", $0)
	}.joined()
}

// MARK: - Helper functions for creating encoders and decoders

public func newJSONDecoder() -> JSONDecoder {
	let decoder = JSONDecoder()
	if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
		decoder.dateDecodingStrategy = .iso8601
	}
	return decoder
}

public func newJSONEncoder() -> JSONEncoder {
	let encoder = JSONEncoder()
	if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
		encoder.dateEncodingStrategy = .iso8601
	}
	return encoder
}

extension URLSession {
	public func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.dataTask(with: url) { data, response, error in
			guard let data = data, error == nil else {
				completionHandler(nil, nil, response, error)
				return
			}
			completionHandler(try? newJSONDecoder().decode(T.self, from: data), data, response, nil)
		}
	}
	
	public func codableTask<T: Codable>(with request: URLRequest, completionHandler: @escaping (T?, Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		return self.dataTask(with: request) { data, response, error in
			guard let data = data, error == nil else {
				completionHandler(nil, nil, response, error)
				return
			}
			completionHandler(try? newJSONDecoder().decode(T.self, from: data), data,  response, nil)
		}
	}
}




extension UIColor {
	
	class func randomColor() -> UIColor {
		
		let hue = CGFloat(arc4random() % 100) / 100
		let saturation = CGFloat(arc4random() % 100) / 100
		let brightness = CGFloat(arc4random() % 100) / 100
		
		return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1.0)
	}
}


extension UITableView {
	func reloadData(completion:@escaping ()->()) {
		UIView.animate(withDuration: 0, animations: { self.reloadData() })
		{ _ in completion() }
	}
}

extension UICollectionView {
	func reloadData(completion:@escaping ()->()) {
		UIView.animate(withDuration: 0, animations: { self.reloadData() })
		{ _ in completion() }
	}
}

extension Date {
	
	static func - (lhs: Date, rhs: Date) -> TimeInterval {
		return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
	}
	
}




public protocol ImagePickerDelegate: class {
	func didSelect(image: UIImage?)
}


