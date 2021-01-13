//
//  ValidationWorker.swift
//  ProductList
//
//  Created by vitalii on 29.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
import Validator

class ValidationWorker: NSObject {
    func validateEmail(email : String) -> ValidationResult{
        var result =  email.validate(rule: MyProjectValidatorRules.minLengthRule)
        if(result != .valid){
            return result
        }
        
        result =  email.validate(rule: MyProjectValidatorRules.maxLengthRule)
        if(result != .valid){
            return result
        }
        
        result = email.validate(rule: MyProjectValidatorRules.emailRule)
        if(result != .valid){
            return result
        }
        
        
        return .valid
    }
	
	func validateUname(uname : String) -> ValidationResult{
		var result =  uname.validate(rule: MyProjectValidatorRules.minLengthRule)
		if(result != .valid){
			return result
		}
		
		result =  uname.validate(rule: MyProjectValidatorRules.maxLengthRule)
		if(result != .valid){
			return result
		}
		
		result = uname.validate(rule: MyProjectValidatorRules.unameRule)
		if(result != .valid){
			return result
		}
		
		
		return .valid
	}
    
    func validateIsEmpty(value : String) -> ValidationResult{
        let result =  value.validate(rule: MyProjectValidatorRules.minLengthRule)
        if(result != .valid){
            return result
        }
        return .valid
    }
    
    func getValidationErrorMessage(validationResult : ValidationResult?) -> NSAttributedString?{
        let attributes = [NSAttributedString.Key.foregroundColor : AppManager.appStyle.color(for: .error),
                          NSAttributedString.Key.font : AppManager.appStyle.font(for: .error)]
        
        
        guard let validationResult = validationResult else {
            return nil
        }
        
        var attributed : NSAttributedString?
        
        switch validationResult {
        case .invalid(let errors):
            if(errors.count > 0){
                attributed = NSAttributedString(string: errors.first?.message ?? "NO error", attributes: attributes)
            }
        case .valid:
            attributed = NSAttributedString(string: "")
        }
        return attributed
    }
}
