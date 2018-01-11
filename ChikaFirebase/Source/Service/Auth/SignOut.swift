//
//  SignOut.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseAuth

public class SignOut: ChikaCore.SignOut {

    var auth: FirebaseAuth.Auth
    
    public init(auth: FirebaseAuth.Auth) {
        self.auth = auth
    }
    
    public convenience init() {
        let auth = FirebaseAuth.Auth.auth()
        self.init(auth: auth)
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
