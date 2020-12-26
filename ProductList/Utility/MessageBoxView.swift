//
//  MessageBoxView.swift
//  Battleship
//
//  Created by vitalii on 4/22/20.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import UIKit

class MessageBoxView: UIView {
	var message: String! {
		willSet(text) {
			messageLabel.text = text
		}
	}

	var messageColor: UIColor! {
		didSet {
			coloredDotView.backgroundColor = messageColor
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)

		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .gray

		addSubview(messageLabel)
		addSubview(coloredDotView)
		addConstraints()
	}

	private func addConstraints() {
		NSLayoutConstraint.activate([
			messageLabel.pin(\UIView.topAnchor),
			messageLabel.pin(\UIView.rightAnchor),
			messageLabel.pin(\UIView.bottomAnchor),
			coloredDotView.pin(\UIView.topAnchor),
			coloredDotView.pin(\UIView.bottomAnchor),
			coloredDotView.pin(\UIView.leftAnchor),
			coloredDotView.rightAnchor.constraint(equalTo: messageLabel.leftAnchor),
			coloredDotView.widthAnchor.constraint(equalToConstant: 10),
		])
	}

	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func layoutSubviews() {
		super.layoutSubviews()

		layer.shadowPath = UIBezierPath(rect: bounds).cgPath
		layer.shadowColor = UIColor.darkGray.cgColor
		layer.masksToBounds = false
		layer.shadowOffset = .zero
		layer.shadowRadius = 10
		layer.shadowOpacity = 0.5
	}

	private lazy var messageLabel: UILabel = {
		let l = UILabel()
		l.translatesAutoresizingMaskIntoConstraints = false
		l.adjustsFontSizeToFitWidth = true
		l.textColor = .white
		l.font = .preferredFont(forTextStyle: .headline)
		l.textAlignment = .center
		return l
	}()

	private lazy var coloredDotView: UIView = {
		let v = UIView()
		v.translatesAutoresizingMaskIntoConstraints = false
		return v
	}()
}

extension UIView {
	func pin<LayoutAnchorType, Axis>(_ anchor: KeyPath<UIView, LayoutAnchorType>) -> NSLayoutConstraint
		where LayoutAnchorType: NSLayoutAnchor<Axis> {
			return pin(anchor, to: anchor)
	}
	
	func pin<LayoutAnchorType, Axis>(_ from: KeyPath<UIView, LayoutAnchorType>,
									 to: KeyPath<UIView, LayoutAnchorType>) -> NSLayoutConstraint
		where LayoutAnchorType: NSLayoutAnchor<Axis> {
			guard let parent = superview else { fatalError("must addSubview first") }
			
			let source = self[keyPath: from]
			let target = parent[keyPath: to]
			return source.constraint(equalTo: target)
	}
	
	func pin(_ anchor: KeyPath<UIView, NSLayoutDimension>, to constant: CGFloat) -> NSLayoutConstraint {
		return self[keyPath: anchor].constraint(equalToConstant: constant)
	}
}
