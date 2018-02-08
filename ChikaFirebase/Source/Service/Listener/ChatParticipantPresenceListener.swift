//
//  ChatParticipantPresenceListener.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 2/8/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ChatParticipantPresenceListener: ChikaCore.ChatParticipantPresenceListener {

    var meID: String
    var handles: [ID: Double]
    var database: Database
    var presenceListener: ChikaCore.PresenceListener
    
    public init(meID: String, database: Database, presenceListener: ChikaCore.PresenceListener) {
        self.meID = meID
        self.handles = [:]
        self.database = database
        self.presenceListener = presenceListener
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let presenceListener = PresenceListener(meID: meID, database: database)
        self.init(meID: meID, database: database, presenceListener: presenceListener)
    }
    
    public func stopAll() -> Bool {
        guard !handles.isEmpty else {
            return false
        }
        
        let ok = handles.flatMap({ stopListening(on: $0.key ) }).reduce(true, { $0 && $1 })
        return ok && presenceListener.stopAll()
    }
    
    public func stopListening(on chatID: ID) -> Bool {
        let ok = presenceListener.stopListening(on: chatID)
        
        guard handles[chatID] != nil else {
            return false
        }
        
        handles.removeValue(forKey: chatID)
        return ok
    }
    
    public func startListening(on chatID: ID, callback: @escaping (Result<ChatParticipantPresenceListenerObject>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            callback(.err(Error("current user ID is empty")))
            return false
        }
        
        guard handles[chatID] == nil else {
            callback(.err(Error("already listening when participant's presence changes in chat")))
            return false
        }
        
        let handle = Date().timeIntervalSince1970
        
        let stopListeningBlock = stopListening
        let queryParticipantsBlock = queryChatParticipants
        
        let creatorRef = database.reference().child("chats/\(chatID)/creator")
        
        creatorRef.observeSingleEvent(of: .value, with: { snapshot in
            guard !snapshot.exists() else {
                callback(.err(Error("can not listen participant presence in a group chat")))
                let _ = stopListeningBlock(chatID)
                return
            }
            
            queryParticipantsBlock(chatID, callback)
            
        }) { error in
            callback(.err(error))
        }
        
        handles[chatID] = handle
        
        return true
    }
    
    private func queryChatParticipants(_ chatID: ID, _ callback: @escaping (Result<ChatParticipantPresenceListenerObject>) -> Void) {
        let authUserID = meID
        let stopListeningBlock = stopListening
        let listenParticipantPresenceBlock = listenParticipantPresence
        
        let query = database.reference().child("chat:participants/\(chatID)/").queryOrderedByKey()
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                callback(.err(Error("snapshot value is not a dictionary")))
                let _ = stopListeningBlock(chatID)
                return
            }
            
            let keys = value.flatMap({ $0.key }).filter({ $0 != authUserID })
            
            guard keys.count == 1, let personID = keys.first else {
                callback(.err(Error("contact chat has more than 2 participants")))
                let _ = stopListeningBlock(chatID)
                return
            }
            
            listenParticipantPresenceBlock(ID(personID), chatID, callback)
            
        }) { error in
            callback(.err(error))
        }
    }
    
    private func listenParticipantPresence(_ personID: ID, _ chatID: ID, _ callback: @escaping (Result<ChatParticipantPresenceListenerObject>) -> Void) {
        let _ = presenceListener.startListening(on: personID) { result in
            switch result {
            case .ok(let presence):
                let object = ChatParticipantPresenceListenerObject(chatID: chatID, presence: presence)
                callback(.ok(object))
            
            case .err(let error):
                callback(.err(error))
            }
        }
    }
    
}
