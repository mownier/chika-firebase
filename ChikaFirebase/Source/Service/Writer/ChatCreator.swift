//
//  ChatCreator.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/19/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ChatCreator: ChikaCore.ChatCreator {

    var meID: String
    var database: Database
    var chatQuery: ChikaCore.ChatQuery
    
    public init(meID: String, database: Database, chatQuery: ChikaCore.ChatQuery) {
        self.meID = meID
        self.database = database
        self.chatQuery = chatQuery
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let chatQuery = ChatQuery(meID: meID, database: database)
        self.init(meID: meID, database: database, chatQuery: chatQuery)
    }
    
    public func createChat(withTitle title: String, participantIDs: [ID], photoURL: String, completion: @escaping (Result<Chat>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        var personIDs = participantIDs
        personIDs.append(ID(meID))
        personIDs = Array(Set(personIDs)).filter({ !"\($0)".isEmpty })
        
        guard personIDs.count > 1 else {
            completion(.err(Error("not enough participants")))
            return false
        }
        
        let rootRef = database.reference()
        let (chatID, values) = getChatIDAndValuesForUpdate(title, personIDs, photoURL)
        let getCreatedChatBlock = getCreatedChat
        
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            getCreatedChatBlock(chatID, completion)
        }
        
        return true
    }
    
    private func getCreatedChat(_ chatID: ID, _ completion: @escaping (Result<Chat>) -> Void) {
        let chatIDs = [chatID]
        let _ = chatQuery.getChats(for: chatIDs) { result in
            switch result {
            case .ok(let chats):
                guard chatIDs.count == chats.count,
                    chatIDs == chats.map({ $0.id }) else {
                        completion(.err(Error("could not get newly created chat")))
                        return
                }
                
                completion(.ok(chats[0]))
                
            case .err(let error):
                completion(.err(error))
            }
        }
    }
    
    private func getChatIDAndValuesForUpdate(_ title: String, _ personIDs: [ID], _ photoURL: String) -> (ID, [String: Any]) {
        let rootRef = database.reference()
        let chatsRef = rootRef.child("chats")
        
        let title = title.isEmpty ? "New Chat" : title
        let chatKey = chatsRef.childByAutoId().key
        let timestamp = ServerValue.timestamp()
        
        var values: [String: Any] = [:]
        
        values["chat:participant:title/\(chatKey)/\(meID)"] = title
        
        for personID in personIDs {
            values["person:inbox/\(personID)/\(chatKey)/participant:since"] = timestamp
            values["chat:participants/\(chatKey)/\(personID)"] = true
        }
        
        values["chats/\(chatKey)/id"] = chatKey
        values["chats/\(chatKey)/title"] = title
        values["chats/\(chatKey)/creator"] = meID
        values["chats/\(chatKey)/created:on"] = timestamp
        values["chats/\(chatKey)/updated:on"] = timestamp
        values["chat:participant:count/\(chatKey)"] = personIDs.count
        
        if !photoURL.isEmpty {
            values["chats/\(chatKey)/photo:url"] = photoURL
        }
        
        return (ID(chatKey), values)
    }
}
