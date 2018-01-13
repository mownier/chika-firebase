//
//  RecentChatMessageQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseDatabase

public class RecentChatMessageQuery: ChikaCore.RecentChatMessageQuery {

    var database: Database
    
    public init(database: Database = Database.database()) {
        self.database = database
    }
    
    public func getRecentChatMessage(of chatID: ID, completion: @escaping (Result<Message>) -> Void) -> Bool {
        return true
    }
}
