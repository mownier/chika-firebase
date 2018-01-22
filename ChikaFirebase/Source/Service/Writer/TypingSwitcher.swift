//
//  TypingSwitcher.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/22/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class TypingSwitcher: ChikaCore.TypingSwitcher {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func switchTypingStatus(to status: TypingStatus, for chatID: ID, completion: @escaping (Result<OK>) -> Void) -> Bool {
        let isTyping = status == .typing ? true : false
        let typingStatusRef = database.reference().child("chat:typing:status/\(chatID)/\(meID)")
        

        typingStatusRef.setValue(isTyping) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("switched typing status successfully")))
        }

        return true
    }
    
}
