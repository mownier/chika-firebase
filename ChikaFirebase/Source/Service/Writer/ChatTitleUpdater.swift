//
//  ChatTitleUpdater.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/19/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ChatTitleUpdater: ChikaCore.ChatTitleUpdater {

    var database: Database
    
    public init(database: Database = Database.database()) {
        self.database = database
    }
    
    public func updateTitle(_ title: String, of chatID: ID, completion: @escaping (Result<OK>) -> Void) -> Bool {
        let rootRef = database.reference()
        let values = ["chats/\(chatID)/title" : title]
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("chat title updated successfully")))
        }
        return true
    }
    
}
