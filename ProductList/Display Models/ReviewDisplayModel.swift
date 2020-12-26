//
//  ComicDisplayModel.swift
//  ComicsCharacters
//
//  Created by vitalii on 16.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit
import Foundation

struct ReviewDisplayModel: Hashable {
	let username: String
	let fullName: String
	var portraitImage: UIImage?
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(MD5(username+fullName))
	}
}
