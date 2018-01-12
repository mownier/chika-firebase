//
//  FirebaseAuthUserMock.swift
//  ChikaFirebaseTests
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import FirebaseAuth

class FirebaseAuthUserMock: User {

    var error: Swift.Error?
    var token: String?
    
    var mockID: String
    var mockEmail: String?
    var mockRefreshToken: String?
    
    init(id: String) {
        self.mockID = id
    }
    
    override var uid: String {
        return mockID
    }
    
    override var email: String? {
        return mockEmail
    }
    
    override var refreshToken: String? {
        return mockRefreshToken
    }
    
    override func getIDToken(completion: AuthTokenCallback? = nil) {
        getIDTokenForcingRefresh(false, completion: completion)
    }
    
    override func updateEmail(to email: String, completion: UserProfileChangeCallback? = nil) {
        completion?(error)
    }
    
    override func updatePassword(to password: String, completion: UserProfileChangeCallback? = nil) {
        completion?(error)
    }
    
    override func getIDTokenForcingRefresh(_ forceRefresh: Bool, completion: AuthTokenCallback? = nil) {
        completion?(token, error)
    }
    
}
