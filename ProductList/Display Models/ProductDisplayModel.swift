//
//  CharacterDisplayModel.swift
//  ComicsCharacters
//
//  Created by vitalii on 30.10.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
import UIKit

struct ProductDisplayModel: Hashable {
	let title: String
	var productImage: UIImage?
	let description: String
	
	func hash(into hasher: inout Hasher) {
		hasher.combine(MD5(title))
	}
}




