//
//  MessageQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class MessageQuery: ChikaCore.MessageQuery {

    var database: Database
    
    public init(database: Database) {
        self.database = database
    }
    
    public func getMessages(for messageIDs: [ID], completion: @escaping (Result<[Message]>) -> Void) -> Bool {
        return true
    }
}
