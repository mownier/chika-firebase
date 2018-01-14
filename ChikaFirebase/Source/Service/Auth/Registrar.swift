//
//  Registrar.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class Registrar: ChikaCore.Registrar {

    var auth: FirebaseCommunity.Auth
    var authValidator: AuthValidator
    
    public init(auth: FirebaseCommunity.Auth = FirebaseCommunity.Auth.auth(), authValidator: AuthValidator = AuthValidation()) {
        self.auth = auth
        self.authValidator =  authValidator
    }
    
    public func register(withEmail email: String, password: String, completion: @escaping (Result<ChikaCore.Auth>) -> Void) -> Bool {
        let validator = authValidator
        auth.createUser(withEmail: email, password: password) { user, error in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            guard let user = user else {
                completion(.err(Error("no authenticated user")))
                return
            }
            
            user.getIDToken { token, error in
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
        }
        return true
    }
}
