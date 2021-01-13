//
//  UIViewController+Hud.swift
//  Battleship
//
//  Created by vitalii on 02.06.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
import JGProgressHUD

protocol HudProtocol {
	func showHud()
	func showHud(_ status: String)
	func removeHud()
}

class Hud {
	static let shared = Hud()
	 let hud = JGProgressHUD()
	func show(in view: UIView, with status: String){
		hud.textLabel.text = status
		hud.show(in: view)
	}
	func show(in view: UIView){
		hud.show(in: view)
	}
	func dismiss(){
		hud.dismiss()
	}
}

extension UIViewController: HudProtocol {
	func showHud(_ status: String) {
		DispatchQueue.main.async { [weak self] in
			if let view = self?.view {
				Hud.shared.show(in: view, with: status)
				view.isUserInteractionEnabled = false
			}
		}
	}

	func showHud() {
		DispatchQueue.main.async { [weak self] in
			if let view = self?.view {
				Hud.shared.show(in: view)
				view.isUserInteractionEnabled = false
			}
		}
	}

	func removeHud() {
		DispatchQueue.main.async { [weak self] in
			if let view = self?.view {
				Hud.shared.dismiss()
				view.isUserInteractionEnabled = true
			}
		}
	}
}
