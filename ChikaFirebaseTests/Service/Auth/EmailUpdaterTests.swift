//
//  EmailUpdaterTests.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import XCTest
import ChikaCore
import FirebaseCommunity
@testable import ChikaFirebase

class EmailUpdaterTests: XCTestCase {
    
    var auth: FirebaseAuthMock!
    var updater: ChikaFirebase.EmailUpdater!
    
    override func setUp() {
        super.setUp()
        
        auth = FirebaseAuthMock()
        updater = EmailUpdater(auth: auth)
    }
    
    func testUpdateEmailA() {
        let exp = expectation(description: "testUpdateEmailA")
        auth.mockUser = auth.mockAuthenticatedUser
        let ok = updater.updateEmail(withNew: "you@you.com", currentEmail: "me@me.com", currentPassword: "me12345") { result in
            switch result {
            case .ok: break
            case .err: XCTFail()
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testUpdateEmailB() {
        let exp = expectation(description: "testUpdateEmailB")
        auth.mockUser = nil
        let ok = updater.updateEmail(withNew: "you@you.com", currentEmail: "me@me.com", currentPassword: "me12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testUpdateEmailC() {
        let exp = expectation(description: "testUpdateEmailC")
        let ok = updater.updateEmail(withNew: "you@you.com", currentEmail: "me@me.com", currentPassword: "wrongPassword") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testUpdateEmailD() {
        let exp = expectation(description: "testUpdateEmailD")
        let user = auth.mockAuthenticatedUser
        user.error = ChikaCore.Error("forced error")
        auth.mockUser = user
        let ok = updater.updateEmail(withNew: "you@you.com", currentEmail: "me@me.com", currentPassword: "me12345") { result in
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
