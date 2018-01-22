//
//  AcceptContactRequestAction.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/18/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class AcceptContactRequestAction: ChikaCore.AcceptContactRequestAction {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func acceptContactRequest(withID id: ID, requestorID: ID, completion: @escaping (Result<OK>) -> Void) -> Bool {
        let rootRef = database.reference()
        let chatsRef = rootRef.child("chats")
        
        let chatKey = chatsRef.childByAutoId().key
        let timestamp = ServerValue.timestamp()
        
        let newChat: [String: Any] = [
            "created:on": timestamp,
            "updated:on": timestamp,
            "id": chatKey,
            "participants":[
                "\(meID)": true,
                "\(requestorID)": true
            ]
        ]
        
        let values: [AnyHashable: Any] = [
            "chats/\(chatKey)": newChat,
            "person:contacts/\(requestorID)/\(meID)/chat": chatKey,
            "person:contacts/\(meID)/\(requestorID)/chat": chatKey,
            "person:contact:request:established/\(requestorID)/\(meID)": NSNull(),
            "person:contact:request:established/\(meID)/\(requestorID)": NSNull(),
            "contact:requests/\(id)": NSNull()
        ]
        
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("accepted contact request")))
        }
        
        return true
    }
    
}
