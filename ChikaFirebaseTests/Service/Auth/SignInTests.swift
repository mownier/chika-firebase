//
//  SignInTests.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import XCTest
import ChikaCore
import FirebaseAuth
@testable import ChikaFirebase

class SignInTests: XCTestCase {
    
    var auth: FirebaseAuthMock!
    var task: ChikaFirebase.SignIn!
    
    override func setUp() {
        super.setUp()
        
        auth = FirebaseAuthMock()
        task = ChikaFirebase.SignIn(auth: auth)
    }
    
    func testSignInA() {
        auth.mockUser = auth.createAuthenticatedUser(withEmail: "me@me.com")
        auth.error = nil
        let exp = expectation(description: "testSignInA")
        let ok = task.signIn(withEmail: "me@me.com", password: "me12345") { result in
            switch result {
            case .ok: break
            case .err: XCTFail()
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSignInB() {
        let exp = expectation(description: "testSignInB")
        let ok = task.signIn(withEmail: "me@me.com", password: "wrongPassword") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSignInC() {
        let exp = expectation(description: "testSignInC")
        let ok = task.signIn(withEmail: "notFound@email.com", password: "me12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSignInD() {
        auth.mockUser = auth.createAuthenticatedUser(withEmail: "me@me.com")
        auth.mockUser?.error = Error("forced error")
        auth.error = nil
        let exp = expectation(description: "testSignInD")
        let ok = task.signIn(withEmail: "me@me.com", password: "me12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSignInE() {
        auth.mockUser = auth.createAuthenticatedUser(withEmail: "me@me.com")
        auth.mockUser?.token = ""
        auth.mockUser?.error = nil
        auth.error = nil
        let exp = expectation(description: "testSignInE")
        let ok = task.signIn(withEmail: "me@me.com", password: "me12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSignInF() {
        auth.mockUser = auth.createAuthenticatedUser(withEmail: "me@me.com")
        auth.mockUser?.token = "accessToken"
        auth.mockUser?.mockEmail = nil
        auth.mockUser?.mockRefreshToken = nil
        auth.mockUser?.error = nil
        auth.error = nil
        let exp = expectation(description: "testSignInF")
        let ok = task.signIn(withEmail: "me@me.com", password: "me12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testSignInG() {
        auth.mockUser = nil
        auth.error = nil
        let exp = expectation(description: "testSignInG")
        let ok = task.signIn(withEmail: "me@me.com", password: "me12345") { result in
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
