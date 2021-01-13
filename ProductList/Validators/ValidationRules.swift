//
//  ValidationRules.swift
//  ProductList
//
//  Created by vitalii on 29.11.2020.
//  Copyright © 2020 Vitalii. All rights reserved.
//

import Foundation
import Validator

enum ErrorCodes : Error{
    case required
    case invalidEmail
	case invalidUname
    case invalidMobile
    case minLength
    case maxLength
}

struct MyProjectErrorCode : ValidationError {
    var message: String
    var errorCode : ErrorCodes
}

class MyProjectValidatorRules: NSObject {
    let errorDomain = "ProductList"
	static let unameRule = ValidationRulePattern(pattern: "([a-zA-Z0-9@*#!]{4,20})", error: MyProjectErrorCode(message: "Min length", errorCode: ErrorCodes.required))
    static let emailRule = ValidationRulePattern(pattern: EmailValidationPattern.standard, error: MyProjectErrorCode(message: "Invalid email", errorCode: ErrorCodes.invalidEmail))
    static let minLengthRule = ValidationRuleLength(min: 1, error: MyProjectErrorCode(message: "Min length", errorCode: ErrorCodes.minLength))
    static let maxLengthRule = ValidationRuleLength(max: 20, error: MyProjectErrorCode(message: "Min length", errorCode: ErrorCodes.maxLength))
    static let passwordValidtion =  ValidationRulePattern(pattern: "([a-zA-Z0-9@*#!]{4,20})", error: MyProjectErrorCode(message: "Min length", errorCode: ErrorCodes.required))
}
