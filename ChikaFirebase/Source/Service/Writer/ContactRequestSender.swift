//
//  ContactRequestSender.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/19/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ContactRequestSender: ChikaCore.ContactRequestSender {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func sendContactRequest(to personID: ID, message: String, completion: @escaping (Result<OK>) -> Void) -> Bool {
        let rootRef = database.reference()
        let requestsRef = rootRef.child("contact:requests")
        
        let requestKey = requestsRef.childByAutoId().key
        
        let newRequest: [AnyHashable: Any] = [
            "id": requestKey,
            "message": message,
            "requestor": meID,
            "requestee": personID,
            "created:on": ServerValue.timestamp()
        ]
        
        let values: [AnyHashable: Any] = [
            "contact:requests/\(requestKey)": newRequest,
            "person:contact:request:established/\(meID)/\(personID)": newRequest,
            "person:contact:request:established/\(personID)/\(meID)": newRequest
        ]
        
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("contact request sent")))
        }
        
        return true
    }
    
}
