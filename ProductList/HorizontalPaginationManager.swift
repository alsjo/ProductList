//
//  HorizontalPaginationManager.swift
//  ComicsCharacters
//
//  Created by vitalii on 28.10.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
import UIKit


enum ScrollDirection{
	case vertical, horisontal
}

protocol HorizontalPaginationManagerDelegate: class {
	func refreshAll(completion: @escaping (Bool) -> Void)
	func loadMore(completion: @escaping (Bool) -> Void)
	func increaseCollection(completion: @escaping (Bool) -> Void)
}

protocol VerticalPaginationManagerDelegate: class {
	func refreshAllComics(at index: Int, completion: @escaping (Bool) -> Void)
	func loadMoreComics(at index: Int, completion: @escaping (Bool, Int) -> Void)
	func increaseCollection(at index: Int, completion: @escaping (Bool) -> Void)
}

class HorizontalPaginationManager: NSObject {
	
	var isEverythingLoaded = false
	var isLoading = false
	var isObservingKeyPath: Bool = false
	var scrollView: UIScrollView!
	var leftMostLoader: UIView?
	var rightMostLoader: UIView?
	var refreshViewColor: UIColor = .white
	var loaderColor: UIColor = .white
	var itemsPerLoad: Int!
	var loadedItems = 0
	var items = SynchronizedArray<Int>()
	var offset: CGPoint = CGPoint(x: 0.0, y: 0.0)
	var scrollDirection: ScrollDirection!
	var itemLength: CGFloat!
	weak var delegate: HorizontalPaginationManagerDelegate?
	
	init(scrollView: UIScrollView, itemsPerLoad: Int = 20, scrollDirection: ScrollDirection = .horisontal, itemLength: CGFloat = 130) {
		super.init()
		self.scrollDirection = scrollDirection
		self.itemLength = itemLength
		self.itemsPerLoad = itemsPerLoad
		self.scrollView = scrollView
		self.addScrollViewOffsetObserver()
	}
	
	deinit {
		self.removeScrollViewOffsetObserver()
	}	
}

extension HorizontalPaginationManager {
	
	@objc func initialLoad() {
		self.isLoading = true
		self.delegate?.refreshAll { [weak self] success in
			self?.isLoading = false
			if success == true {
				self?.loadedItems += self?.itemsPerLoad ?? 20
			}
		}
	}
}

// MARK: ADD LEFT LOADER
extension HorizontalPaginationManager {
	
	private func addLeftMostControl() {
		let view = UIView()
		view.backgroundColor = self.refreshViewColor
		view.frame.origin = CGPoint(x: -60, y: 0)
		view.frame.size = CGSize(width: 60,
								 height: self.scrollView.bounds.height)
		let activity = UIActivityIndicatorView(style: .gray)
		activity.color = self.loaderColor
		activity.frame = view.bounds
		activity.startAnimating()
		view.addSubview(activity)
		self.scrollView.contentInset.left = view.frame.width
		self.leftMostLoader = view
		self.scrollView.addSubview(view)
	}
	
	func removeLeftLoader() {
		self.leftMostLoader?.removeFromSuperview()
		self.leftMostLoader = nil
		self.scrollView.contentInset.left = 0
		self.scrollView.setContentOffset(.zero, animated: true)
	}
	
}

// MARK: RIGHT LOADER
extension HorizontalPaginationManager {
	
	private func addRightMostControl() {
		let view = UIView()
		view.backgroundColor = self.refreshViewColor
		view.frame.origin = CGPoint(x: self.scrollView.contentSize.width,
									y: 0)
		view.frame.size = CGSize(width: 60,
								 height: self.scrollView.bounds.height)
		let activity = UIActivityIndicatorView(style: .gray)
		activity.color = self.loaderColor
		activity.frame = view.bounds
		activity.startAnimating()
		view.addSubview(activity)
		DispatchQueue.main.async { [unowned self] in
			self.scrollView.contentInset.right = view.frame.width
			self.rightMostLoader = view
			self.scrollView.addSubview(view)
		}
	}
	
	func removeRightLoader() {
		DispatchQueue.main.async { [unowned self] in
			self.rightMostLoader?.removeFromSuperview()
			self.rightMostLoader = nil
		}
	}
	
}

// MARK: OFFSET OBSERVER
extension HorizontalPaginationManager {
	
	func addScrollViewOffsetObserver() {
		if self.isObservingKeyPath { return }
		self.scrollView.addObserver(
			self,
			forKeyPath: "contentOffset",
			options: [.new],
			context: nil
		)
		self.isObservingKeyPath = true
	}
	
	func removeScrollViewOffsetObserver() {
		if self.isObservingKeyPath {
			self.scrollView.removeObserver(self,
										   forKeyPath: "contentOffset")
		}
		self.isObservingKeyPath = false
	}
	
	override public func observeValue(forKeyPath keyPath: String?,
									  of object: Any?,
									  change: [NSKeyValueChangeKey : Any]?,
									  context: UnsafeMutableRawPointer?) {
		guard let object = object as? UIScrollView,
			let keyPath = keyPath,
			let newValue = change?[.newKey] as? CGPoint,
			object == self.scrollView, keyPath == "contentOffset" else { return }
		//print("offset: \(newValue.y)")
		self.setContentOffSet(newValue)
	}
	
	private func setContentOffSet(_ offset: CGPoint) {
		self.offset = offset

		
		if loadedItems > items.count - itemsPerLoad/2 && !self.isLoading {
			increaseCollection()
		}
		else{
			let offset = scrollDirection == .horisontal ? self.offset.x : self.offset.y
			if  offset > self.itemLength * CGFloat(loadedItems - itemsPerLoad/2) && !self.isLoading && !self.isEverythingLoaded {
				loadMoreItems()
			}
		}

	}
	
	@objc func increaseCollection() {
		self.isLoading = true
		self.delegate?.increaseCollection { [weak self] success in
			self?.isLoading = false
		}
	}
	
	@objc func loadMoreItems() {
		self.isLoading = true
		self.delegate?.loadMore { [weak self] success in
			self?.isLoading = false
			
			if success == true {
				self?.loadedItems += self?.itemsPerLoad ?? 20
			}
		}
	}
	
}


class VerticalPaginationManager: HorizontalPaginationManager {
	var index: Int!
	weak var verticalDelegate: VerticalPaginationManagerDelegate?
	init(index: Int, scrollView: UIScrollView, itemsPerLoad: Int = 20, scrollDirection: ScrollDirection = .horisontal, itemLength: CGFloat = 130) {
		super.init(scrollView: scrollView, itemsPerLoad: itemsPerLoad, scrollDirection: scrollDirection, itemLength: itemLength)
		self.index = index
	}
}

extension VerticalPaginationManager {
	
	override func initialLoad() {
		self.isLoading = true
		self.verticalDelegate?.refreshAllComics(at: self.index) { [weak self] success in
			self?.isLoading = false
			if success == true {
				self?.loadedItems += self?.itemsPerLoad ?? 20
			}
		}
	}
	
	override func increaseCollection() {
		self.isLoading = true
		self.verticalDelegate?.increaseCollection(at: self.index) { [weak self] success in
			self?.isLoading = false
		}
	}
	
	override func loadMoreItems() {
		self.isLoading = true

		self.verticalDelegate?.loadMoreComics(at: self.index) { [weak self] success, count in
			self?.isLoading = false

			if success == true {
				self?.loadedItems += count
				if count < self?.itemsPerLoad ?? 20 {
					self?.isEverythingLoaded = true
				}
			}
			
		}
	}
}
