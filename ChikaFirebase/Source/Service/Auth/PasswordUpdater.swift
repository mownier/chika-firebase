//
//  PasswordUpdater.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseAuth

public class PasswordUpdater: ChikaCore.PasswordUpdater {

    var auth: FirebaseAuth.Auth
    
    public init(auth: FirebaseAuth.Auth = FirebaseAuth.Auth.auth()) {
        self.auth = auth
    }
    
    public func updatePassword(withNew newPassword: String, currentPassword: String, currentEmail: String, completion: @escaping (Result<OK>) -> Void) -> Bool {
        auth.signIn(withEmail: currentEmail, password: currentPassword) { user, error in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            guard let user = user else {
                completion(.err(Error("no authenticated user")))
                return
            }
            
            user.updatePassword(to: newPassword) { error in
                guard error == nil else {
                    completion(.err(error!))
                    return
                }
                
                completion(.ok(OK("updated password successfully")))
            }
        }
        return true
    }
}
