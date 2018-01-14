//
//  SignOut.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class SignOut: ChikaCore.SignOut {

    var auth: FirebaseCommunity.Auth
    
    public init(auth: FirebaseCommunity.Auth = FirebaseCommunity.Auth.auth()) {
        self.auth = auth
    }
    
    public func signOut(withCompletion completion: @escaping (Result<OK>) -> Void) -> Bool {
        do {
            try auth.signOut()
            completion(.ok(OK("signed out successfully")))
            
        } catch {
            completion(.err(Error("can not sign out")))
        }
        
        return true
    }
}
