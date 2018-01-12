//
//  SignOutTests.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import XCTest
import ChikaCore
import FirebaseAuth
@testable import ChikaFirebase

class SignOutTests: XCTestCase {
    
    var auth: FirebaseAuthMock!
    var task: ChikaFirebase.SignOut!
    
    override func setUp() {
        super.setUp()
        
        auth = FirebaseAuthMock()
        task = ChikaFirebase.SignOut(auth: auth)
    }
    
    func testSignOutA() {
        auth.error = nil
        auth.mockUser = auth.createAuthenticatedUser(withEmail: "me@me.com")
        let exp = expectation(description: "testSignOutA")
        let ok = task.signOut { result in
            switch result {
            case .ok: break
            case .err: XCTFail()
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSignOutB() {
        auth.error = nil
        auth.mockUser = nil
        let exp = expectation(description: "testSignOutB")
        let ok = task.signOut { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSignOutC() {
        auth.error = Error("forced error")
        auth.mockUser = nil
        let exp = expectation(description: "testSignOutC")
        let ok = task.signOut { result in
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
