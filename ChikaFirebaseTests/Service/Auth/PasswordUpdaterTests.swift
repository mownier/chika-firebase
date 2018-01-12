//
//  PasswordUpdaterTests.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import XCTest
import ChikaCore
import FirebaseAuth
@testable import ChikaFirebase

class PasswordUpdaterTests: XCTestCase {
    
    var auth: FirebaseAuthMock!
    var updater: ChikaFirebase.PasswordUpdater!
    
    override func setUp() {
        super.setUp()
        
        auth = FirebaseAuthMock()
        updater = PasswordUpdater(auth: auth)
    }
    
    func testUpdatePasswordA() {
        let exp = expectation(description: "testUpdatePasswordA")
        auth.mockUser = auth.mockAuthenticatedUser
        let ok = updater.updatePassword(withNew: "me1234", currentPassword: "me12345", currentEmail: "me@me.com") { result in
            switch result {
            case .ok: break
            case .err: XCTFail()
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testUpdatePasswordB() {
        let exp = expectation(description: "testUpdatePasswordB")
        auth.mockUser = nil
        let ok = updater.updatePassword(withNew: "me1234", currentPassword: "me12345", currentEmail: "me@me.com") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testUpdatePasswordC() {
        let exp = expectation(description: "testUpdatePasswordC")
        let ok = updater.updatePassword(withNew: "me1234", currentPassword: "wrongPassword", currentEmail: "me@me.com") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testUpdatePasswordD() {
        let exp = expectation(description: "testUpdatePasswordD")
        let user = auth.mockAuthenticatedUser
        user.error = ChikaCore.Error("forced error")
        auth.mockUser = user
        let ok = updater.updatePassword(withNew: "me1234", currentPassword: "me12345", currentEmail: "me@me.com") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
}
