//
//  NavigationBar.swift
//  SampleAppWithComponents
//
//  Created by Rahul Mane on 20/09/19.
//  Copyright © 2019 developer. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController{
    func setUpNavigationBar(){
        AppManager.appStyle.apply(to: navigationBar)
        AppManager.appStyle.apply(textStyle: .statusBar)
    }
    
    func unHideNavigationBar(){
        AppManager.appStyle.apply(textStyle: .statusBar)
        setNavigationBarHidden(false, animated: false)
    }
    
    func hideNavigationBar(){
        setStatusBarBackgroundColor(color: UIColor.clear)
        setNavigationBarHidden(true, animated: false)
    }
    
    func setStatusBarBackgroundColor(color: UIColor) {
		if #available(iOS 13.0, *) {
			let keyWindow = UIApplication.shared.connectedScenes
				.filter({$0.activationState == .foregroundActive})
				.map({$0 as? UIWindowScene})
				.compactMap({$0})
				.first?.windows
				.filter({$0.isKeyWindow}).first
			let statusBar = UIView(frame: keyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero)
			statusBar.backgroundColor = color
			
			keyWindow?.addSubview(statusBar)
		} else {
			guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
			
			statusBar.backgroundColor = color
		}
       
    }
    
}

