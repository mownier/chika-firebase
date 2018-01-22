//
//  AddChatParticipantsAction.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/18/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class AddChatParticipantsAction: ChikaCore.AddChatParticipantsAction {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func addChatParticipants(withPersonIDs personIDs: [ID], chatID: ID, completion: @escaping (Result<[ID]>) -> Void) -> Bool {
        let rootRef = database.reference()
        let timestamp = ServerValue.timestamp()
        
        var values: [String: Any] = [:]
        
        for personID in personIDs {
            values["person:inbox/\(personID)/\(chatID)/updated:on"] = timestamp
            values["chats/\(chatID)/participants/\(personID)"] = true
        }
        
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(personIDs))
        }
        
        return true
    }
}
