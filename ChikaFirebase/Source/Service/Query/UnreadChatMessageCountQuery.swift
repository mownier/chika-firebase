//
//  UnreadChatMessageCountQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 2/10/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class UnreadChatMessageCountQuery: ChikaCore.UnreadChatMessageCountQuery {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func getUnreadChatMessageCount(for chatID: ID, completion: @escaping (Result<UInt>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        guard !"\(chatID)".isEmpty else {
            completion(.err(Error("empty chat ID")))
            return false
        }
        
        let authUserID = meID
        let rootRef = database.reference()
        let lastReadRef = rootRef.child("person:last:read:chat:message/\(authUserID)/\(chatID)")
        
        lastReadRef.observeSingleEvent(of: .value, with: { snapshot in
            let messageKey = snapshot.value as? String ?? ""
            var chatMessagesRef = rootRef.child("chat:messages/\(chatID)").queryOrderedByKey()
            
            if !messageKey.isEmpty {
                chatMessagesRef = chatMessagesRef.queryStarting(atValue: messageKey)
            }
            
            chatMessagesRef.observeSingleEvent(of: .value, with: { snapshot in
                guard let value = snapshot.value as? [String: Any] else {
                    return
                }
                
                let readStateRef = rootRef.child("chat:message:read:state/\(chatID)")
                
                value.forEach({ item in
                    readStateRef.child("\(item.key)/\(authUserID)").observeSingleEvent(of: .value) { snapshot in
                        guard !snapshot.exists() else {
                            return
                        }
                        
                        completion(.ok(1))
                    }
                })
                
            }) { error in
                completion(.err(error))
            }
            
        }) { error in
            completion(.err(error))
        }
        
        return true
    }
    
}
