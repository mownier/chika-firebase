//
//  IgnoreContactRequestAction.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/19/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class IgnoreContactRequestAction: ChikaCore.IgnoreContactRequestAction {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func ignoreContactRequest(withID id: ID, requestorID: ID, completion: @escaping (Result<OK>) -> Void) -> Bool {
        let rootRef = database.reference()
        let values: [String: Any] = [
            "contact:requests/\(id)": NSNull(),
            "person:contact:request:established/\(requestorID)/\(meID)": NSNull(),
            "person:contact:request:established/\(meID)/\(requestorID)": NSNull()
        ]
        
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("ignored contact request successfully")))
        }
        
        return true
    }
    
}
