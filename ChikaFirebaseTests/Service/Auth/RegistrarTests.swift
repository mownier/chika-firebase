//
//  RegistrarTests.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import XCTest
import ChikaCore
import FirebaseAuth
@testable import ChikaFirebase

class RegistrarTests: XCTestCase {
    
    var auth: FirebaseAuthMock!
    var registrar: ChikaFirebase.Registrar!
    
    override func setUp() {
        super.setUp()
        
        auth = FirebaseAuthMock()
        registrar = ChikaFirebase.Registrar(auth: auth)
    }
    
    func testRegisterA() {
        auth.mockUser = auth.createAuthenticatedUser(withEmail: "you@you.com")
        let exp = expectation(description: "testRegisterA")
        let ok = registrar.register(withEmail: "you@you.com", password: "you12345") { result in
            switch result {
            case .ok: break
            case .err: XCTFail()
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testRegisterB() {
        let exp = expectation(description: "testRegisterB")
        let ok = registrar.register(withEmail: "me@me.com", password: "you12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testRegisterC() {
        auth.mockUser = nil
        let exp = expectation(description: "testRegisterC")
        let ok = registrar.register(withEmail: "you@you.com", password: "you12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testRegisterD() {
        auth.mockUser = nil
        auth.error = Error("forced error")
        let exp = expectation(description: "testRegisterD")
        let ok = registrar.register(withEmail: "you@you.com", password: "you12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testRegisterE() {
        auth.mockUser = auth.createAuthenticatedUser(withEmail: "you@you.com")
        auth.mockUser?.error = Error("forced error")
        auth.error = nil
        let exp = expectation(description: "testRegisterE")
        let ok = registrar.register(withEmail: "you@you.com", password: "you12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
        
    }
    
    func testRegisterF() {
        auth.mockUser = auth.createAuthenticatedUser(withEmail: "you@you.com")
        auth.mockUser?.error = nil
        auth.mockUser?.token = ""
        auth.error = nil
        let exp = expectation(description: "testRegisterF")
        let ok = registrar.register(withEmail: "you@you.com", password: "you12345") { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
 
    func testRegisterG() {
        auth.mockUser = auth.createAuthenticatedUser(withEmail: "you@you.com")
        auth.mockUser?.error = nil
        auth.mockUser?.token = "accessToken"
        auth.mockUser?.mockEmail = nil
        auth.mockUser?.mockRefreshToken = nil
        auth.error = nil
        let exp = expectation(description: "testRegisterF")
        let ok = registrar.register(withEmail: "you@you.com", password: "you12345") { result in
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
