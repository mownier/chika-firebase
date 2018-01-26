//
//  PersonRegistrar.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/22/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class PersonRegistrar: ChikaCore.PersonRegistrar {

    var meID: String
    var email: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", email: String = FirebaseCommunity.Auth.auth().currentUser?.email ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.email = email
        self.database = database
    }
    
    public func registerPerson(withCompletion completion: @escaping (Result<OK>) -> Void) -> Bool {
        var values: [String: Any] = [
            "persons/\(meID)/id": meID,
            "person:email/\(meID)": email
        ]
        
        if let displayName = email.split(separator: "@").first, !displayName.isEmpty {
            values["person:search/\(meID)/email"] = String(displayName)
            values["person:search/\(meID)/display:name"] = String(displayName)

            values["persons/\(meID)/display:name"] = String(displayName)
        }
        
        let rootRef = database.reference()
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("registered person succesfully")))
        }
        
        return true
    }
    
}
