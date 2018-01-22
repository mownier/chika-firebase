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
        var searchValue: [String: String] = [:]
        var personValue = ["id": meID]
        
        if let displayName = email.split(separator: "@").first, !displayName.isEmpty {
            searchValue["email"] = String(displayName)
            searchValue["display:name"] = String(displayName)
            personValue["display:name"] = String(displayName)
        }
        
        let values: [String: Any] = [
            "persons/\(meID)": personValue,
            "persons:search/\(meID)": searchValue,
            
            "person:email/\(meID)/email": email,
            "person:inbox/\(meID)/chat:default:id/updated:on": 0,
            "person:contacts/\(meID)/contact:default:id/chat": "chat:default:id"
        ]
        
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
