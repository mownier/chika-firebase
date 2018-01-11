//
//  AccessTokenRefresher.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseAuth

public class AccessTokenRefresher: ChikaCore.AccessTokenRefresher {

    var user: FirebaseAuth.User?
    var authValidator: AuthValidator
    
    public init(user: FirebaseAuth.User? = FirebaseAuth.Auth.auth().currentUser, authValidator: AuthValidator = AuthValidation()) {
        self.user = user
        self.authValidator = authValidator
    }
    
    public func refreshAccessToken(withCompletion completion: @escaping (Result<ChikaCore.Auth>) -> Void) -> Bool {
        guard let user = user else {
            completion(.err(Error("no user")))
            return false
        }
        
        let validator = authValidator
        user.getIDTokenForcingRefresh(true) { token, error in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            guard let accessToken = token, !accessToken.isEmpty else {
                completion(.err(Error("no access token")))
                return
            }
            
            var auth = ChikaCore.Auth()
            auth.email = user.email ?? ""
            auth.personID = ID(user.uid)
            auth.accessToken = accessToken
            auth.refreshToken = user.refreshToken ?? ""
            
            guard validator.isValidAuth(auth) else {
                completion(.err(Error("auth is not valid")))
                return
            }
            
            completion(.ok(auth))
        }
        
        return true
    }
}
