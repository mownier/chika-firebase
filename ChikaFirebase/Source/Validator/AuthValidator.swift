//
//  AuthExtension.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore

public protocol AuthValidator {
    
    func isValidAuth(_ auth: Auth) -> Bool
}

public class AuthValidation: AuthValidator {
    
    public init() {
    }
    
    public func isValidAuth(_ auth: Auth) -> Bool {
        return !"\(auth.personID)".isEmpty &&
            !auth.email.isEmpty &&
            !auth.accessToken.isEmpty &&
            !auth.refreshToken.isEmpty
    }
}
