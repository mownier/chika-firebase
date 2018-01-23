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
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        guard !"\(personID)".isEmpty else {
            completion(.err(Error("person ID is empty")))
            return false
        }
        
        guard personID != ID(meID) else {
            completion(.err(Error("current user ID must not be equal to person ID")))
            return false
        }
        
        let rootRef = database.reference()
        let requestsRef = rootRef.child("contact:requests")
        
        let requestKey = requestsRef.childByAutoId().key
        
        var newRequest: [AnyHashable: Any] = [
            "id": requestKey,
            "requestor": meID,
            "requestee": "\(personID)",
            "created:on": ServerValue.timestamp()
        ]
        
        let message = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if !message.isEmpty {
            newRequest["message"] = message
        }
        
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
