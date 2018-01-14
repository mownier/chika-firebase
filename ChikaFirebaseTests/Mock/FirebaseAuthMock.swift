//
//  FirebaseAuthMock.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

class FirebaseAuthMock: FirebaseCommunity.Auth {

    var users = [
        "me@me.com": "me12345"
    ]
    
    var error: Swift.Error?
    var mockUser: FirebaseAuthUserMock?
    
    init(user: FirebaseAuthUserMock? = nil) {
        self.mockUser = user
    }
    
    override var currentUser: User? {
        return mockUser
    }
    
    override func signIn(withEmail email: String, password: String, completion: AuthResultCallback? = nil) {
        guard let pass = users[email], password == pass else {
            completion?(nil, Error("invalid credentials"))
            return
        }
        
        completion?(mockUser, nil)
    }
    
    override func createUser(withEmail email: String, password: String, completion: AuthResultCallback? = nil) {
        guard users.contains(where: { $0.key != email }) else {
            completion?(nil, Error("email already exists"))
            return
        }
        
        completion?(mockUser, nil)
    }
    
    override func signOut() throws {
        guard error == nil else {
            throw error!
        }
        
        guard currentUser != nil else {
            throw Error("no current user")
        }
    }
    
    func createAuthenticatedUser(withEmail email: String) -> FirebaseAuthUserMock {
        let user = FirebaseAuthUserMock(id: "person:\(Date().timeIntervalSince1970)")
        user.mockEmail = email
        user.token = "accessToken"
        user.mockRefreshToken = "refreshToken"
        return user
    }
    
    var mockAuthenticatedUser: FirebaseAuthUserMock {
        let user = FirebaseAuthUserMock(id: "person:1")
        user.mockEmail = "me@me.com"
        user.token = "accessToken"
        user.mockRefreshToken = "refreshToken"
        return user
    }
}

