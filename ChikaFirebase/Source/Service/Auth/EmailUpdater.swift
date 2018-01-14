//
//  EmailUpdater.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class EmailUpdater: ChikaCore.EmailUpdater {

    var auth: FirebaseCommunity.Auth
    
    public init(auth: FirebaseCommunity.Auth = FirebaseCommunity.Auth.auth()) {
        self.auth = auth
    }
    
    public func updateEmail(withNew newEmail: String, currentEmail: String, currentPassword: String, completion: @escaping (Result<OK>) -> Void) -> Bool {
        auth.signIn(withEmail: currentEmail, password: currentPassword) { user, error in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            guard let user = user else {
                completion(.err(Error("no authenticated user")))
                return
            }
            
            user.updateEmail(to: newEmail) { error in
                guard error == nil else {
                    completion(.err(error!))
                    return
                }
                
                completion(.ok(OK("updated email successfully")))
            }
        }
        
        return true
    }
}
