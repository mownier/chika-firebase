//
//  AccessTokenRefresherTests.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import XCTest
import ChikaCore
@testable import ChikaFirebase

class AccessTokenRefresherTests: XCTestCase {
    
    var user: FirebaseAuthUserMock!
    var refresher: ChikaFirebase.AccessTokenRefresher!
    
    override func setUp() {
        super.setUp()
        
        user = FirebaseAuthUserMock(id: "person:1")
        refresher = ChikaFirebase.AccessTokenRefresher(user: user)
    }
    
    func testRefreshAccessTokenA() {
        let exp = expectation(description: "testRefreshAccessTokenA")
        
        user.error = Error("forced error")
        
        let ok = refresher.refreshAccessToken { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testRefreshAccessTokenB() {
        let exp = expectation(description: "testRefreshAccessTokenB")
        
        user.error = nil
        user.token = ""
        
        let ok = refresher.refreshAccessToken { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testRefreshAccessTokenC() {
        let exp = expectation(description: "testRefreshAccessTokenC")
        refresher = ChikaFirebase.AccessTokenRefresher(user: nil)
        
        let ok = refresher.refreshAccessToken { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertFalse(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testRefreshAccessTokenD() {
        let exp = expectation(description: "testRefreshAccessTokenD")
        
        user.token = "accessToken"
        
        let ok = refresher.refreshAccessToken { result in
            switch result {
            case .ok: XCTFail()
            case .err: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
    func testRefreshAccessTokenE() {
        let exp = expectation(description: "testRefreshAccessTokenE")
        
        user.token = "accessToken"
        user.mockEmail = "me@me.com"
        user.mockRefreshToken = "refreshToken"
        
        let ok = refresher.refreshAccessToken { result in
            switch result {
            case .err: XCTFail()
            case .ok: break
            }
            exp.fulfill()
        }
        XCTAssertTrue(ok)
        wait(for: [exp], timeout: 1.0)
    }
    
}
