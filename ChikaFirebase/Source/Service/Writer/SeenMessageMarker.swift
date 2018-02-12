//
//  SeenMessageMarker.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 2/11/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class SeenMessageMarker: ChikaCore.SeenMessageMarker {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func markMessageAsSeen(withMessageID messageID: ID, completion: @escaping (Result<OK>) -> Void) -> Bool {
        guard !"\(meID)".isEmpty else {
            completion(.err(Error("current user ID is emtpy")))
            return false
        }
        
        guard !"\(messageID)".isEmpty else {
            completion(.err(Error("empty message ID")))
            return false
        }
        
        let chatRef = database.reference().child("messages/\(messageID)/chat")
        let markSeenBlock = markSeen
        
        chatRef.observeSingleEvent(of: .value, with: { snapshot in
            let chatKey = snapshot.value as? String ?? ""
            markSeenBlock(messageID, ID(chatKey), completion)
            
        }) { error in
            completion(.err(error))
        }
        
        return true
    }
    
    private func markSeen(_ messageID: ID, _ chatID: ID, _ completion: @escaping (Result<OK>) -> Void) {
        let rootRef = database.reference()
        let authUserID = meID
        let readStateValues: [String: Any] = [
            "message:read:state/\(messageID)/\(authUserID)": ["read:on": ServerValue.timestamp()],
            "chat:message:read:state/\(chatID)/\(messageID)/\(authUserID)": true
        ]
        
        rootRef.updateChildValues(readStateValues) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            let messageReadCountRef = rootRef.child("message:read:count/\(messageID)")
            let messageReadStateRef = rootRef.child("message:read:state/\(messageID)/\(authUserID)")
            let chatMessageReadStateRef = rootRef.child("chat:message:read:state/\(chatID)/\(messageID)/\(authUserID)")
            
            messageReadStateRef.onDisconnectRemoveValue()
            chatMessageReadStateRef.onDisconnectRemoveValue()
            
            messageReadCountRef.runTransactionBlock({ data -> TransactionResult in
                guard !(data.value is NSNull) else {
                    return TransactionResult.success(withValue: data)
                }
                
                guard let count = data.value as? Int, count > 0 else {
                    return TransactionResult.abort()
                }
                
                data.value = count + 1
                return TransactionResult.success(withValue: data)
                
            }) { error, committed, ref in
                var isOK = false
                
                defer {
                    if isOK {
                        messageReadStateRef.cancelDisconnectOperations()
                        chatMessageReadStateRef.cancelDisconnectOperations()
                    
                    } else {
                        messageReadStateRef.removeValue()
                        chatMessageReadStateRef.removeValue()
                    }
                }
                
                guard error == nil else {
                    completion(.err(error!))
                    return
                }
                
                guard committed else {
                    completion(.err(Error("increment of message read count is not committed")))
                    return
                }
                
                isOK = true
                completion(.ok(OK("succesfully marked message as seen")))
            }
        }
    }
    
}
