//
//  DataLoadOperation.swift
//  ComicsCharacters
//
//  Created by vitalii on 01.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
import UIKit
class DataLoadOperation: AsynchronousOperation {
	var image: UIImage?
	var loadingCompleteHandler: ((UIImage, Int, Int) -> Void)?
	private var _image: UIImage?
	private let _url: URL
	private let _row: Int
	private let _section: Int // it is hero id for comics
	init(_ image: UIImage?, url: URL, row: Int, section: Int = -1) {
		_image = image
		_url = url
		_row = row
		_section = section
	}
	
	override func main() {
		if isCancelled { return }
		
		if let image = _image {
			self.finish()
			self.image = image
			if let loadingCompleteHandler = self.loadingCompleteHandler {
				loadingCompleteHandler(image, _row, _section)
				return
			}
			
		}
		else {
			
			downloadImage(from: _url, row: _row, section: _section) { [weak self] (image, row, section) in
				//				let category = index2 > -1 ? "\(index2)-" : ""
				guard let self = self else {
					//	print("dataLoader \(category)\(index) == nil")
					return
				}
				self.finish()
				if self.isCancelled {
					return
				}
				if let image = image {
					self.image = image
					if let loadingCompleteHandler = self.loadingCompleteHandler {
						loadingCompleteHandler(image, row, section)
					}
				}
			}
		}
		
		
		
	}
	
	func downloadImage(from url: URL, row: Int, section: Int, completion: @escaping (UIImage?, Int, Int)->()) {
		let category = section > -1 ? "\(section)-" : ""
		//	print("Download \(category)\(index) Started")
		
		Database.shared.getImage(urlString: url.absoluteString) {[weak self] (image) in
			if let image = image {
				completion(image, row, section)
				print("Image \(category)\(row) loaded from db")
			}
			else{
				self?.getData(from: url) { data, response, error in
					guard let data = data, error == nil else { print("image load failed for \(category)\(row)"); completion(nil, row, section); return }
					guard let image = UIImage(data: data) else { print("image parse failed for \(category)\(row)");  return }
					//	print("Download \(category)\(index) Finished")
				
					completion(image, row, section)
					Database.shared.saveImage(urlString: url.absoluteString, image: image)
				}
			}
		}
		
	}
	
	func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
		URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
	}
}
