//
//  UIViewController+Message.swift
//  Battleship
//
//  Created by vitalii on 4/22/20.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit

protocol MessageBoxProtocol {
	func showError(message: String)
	func showSuccess(message: String)
	func showErrorWithCompletion(message: String, completionHandler: ((_: MessageBoxView) -> Void)?)
	func showSuccessWithCompletion(message: String, completionHandler: ((_: MessageBoxView) -> Void)?)
}

enum MessageType {
	case success
	case error
	case info
	
	var color: UIColor {
		switch self {
		case .success: return .green
		case .error: return .red
		case .info: return .yellow
		}
	}
}

extension UIViewController: MessageBoxProtocol {
	
	func showErrorWithCompletion(message: String, completionHandler: ((_: MessageBoxView) -> Void)?) {
		showMessageWithCompletion(withText: message, andType: .error, completionHandler: completionHandler)
	}
	
	func showSuccessWithCompletion(message: String, completionHandler: ((_: MessageBoxView) -> Void)?) {
		showMessageWithCompletion(withText: message, andType: .success, completionHandler: completionHandler)
	}
	
	func showError(message: String) {
		showMessage(withText: message, andType: .error)
	}

	func showSuccess(message: String) {
		showMessage(withText: message, andType: .success)
	}

	
	private func showMessage(withText text: String, andType type: MessageType){
		showMessageWithCompletion(withText: text, andType: type, completionHandler: nil)
	}
	
	private func showMessageWithCompletion(withText text: String, andType type: MessageType, completionHandler: ((_: MessageBoxView) -> Void)?)  {
		DispatchQueue.main.async {
			let v = MessageBoxView()
			v.message = text
			v.messageColor = type.color
			v.alpha = 0
			(self.navigationController?.view ?? self.view).insertSubview(v, at: self.view.subviews.count)

			NSLayoutConstraint.activate([
				v.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 10),
				v.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -10),
				v.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -50),
				v.heightAnchor.constraint(equalToConstant: 50),
			])

			UIView.animate(withDuration: 0.5) {
				v.alpha = 1
			}

			Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
				UIView.animate(withDuration: 0.5, animations: {
					v.alpha = 0
				}, completion: { completed in
					if completed {
						v.removeFromSuperview()
					}
				})
			}
			
			if completionHandler != nil {
				completionHandler!(v)
			}
		}
	}
}
