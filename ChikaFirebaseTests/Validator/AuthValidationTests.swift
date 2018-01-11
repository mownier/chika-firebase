//
//  AuthValidationTests.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import XCTest
import ChikaCore
import ChikaFirebase

class AuthValidationTests: XCTestCase {
    
    func testIsValidF() {
        var auth = Auth()
        let validator = AuthValidation()
        
        auth.email = "me@me.com"
        auth.personID = ID("person:1")
        auth.accessToken = "accessToken"
        auth.refreshToken = "refreshToken"
        
        let ok = validator.isValidAuth(auth)
        XCTAssertTrue(ok)
    }
    
}
