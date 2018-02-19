//
//  ChatQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ChatQuery: ChikaCore.ChatQuery {

    var meID: String
    var database: Database
    var recentChatMessageQuery: ChikaCore.RecentChatMessageQuery
    
    public init(meID: String, database: Database, recentChatMessageQuery: ChikaCore.RecentChatMessageQuery) {
        self.meID = meID
        self.database = database
        self.recentChatMessageQuery = recentChatMessageQuery
    }
    
    public convenience init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        let recentChatMessageQuery = RecentChatMessageQuery(database: database)
        self.init(meID: meID, database: database, recentChatMessageQuery: recentChatMessageQuery)
    }
    
    public func getChats(for chatIDs: [ID], completion: @escaping (Result<[Chat]>) -> Void) -> Bool {
        let chatIDs = chatIDs.filter({ !"\($0)".isEmpty })
        
        guard !chatIDs.isEmpty else {
            completion(.err(Error("empty chatIDs")))
            return false
        }
        
        var chats: [Chat] = []
        var chatCounter: UInt = 0 {
            didSet {
                guard chatCounter == chatIDs.count else {
                    return
                }
                
                completion(.ok(chats))
            }
        }
        
        for chatID in chatIDs {
            getChat(chatID) { chat in
                if chat != nil {
                    chats.append(chat!)
                }
                
                chatCounter += 1
            }
        }
        
        return true
    }
    
    private func getChat(_ chatID: ID, _ chatCounterUpdate: @escaping (Chat?) -> Void) {
        let chatsRef = database.reference().child("chats/\(chatID)")
        let chatMessagesRef = database.reference().child("chat:messages/\(chatID)")
        let getChatTitleBlock = getChatTitle
        let getRecentChatMessageBlock = getRecentChatMessage
        
        chatsRef.observeSingleEvent(of: .value, with: { snapshot in
            guard let info = snapshot.value as? [String : Any] else {
                chatCounterUpdate(nil)
                return
            }
            
            var chat = Chat()
            chat.id = chatID
            chat.title = info["title"] as? String ?? ""
            chat.photoURL = info["photo:url"] as? String ?? ""
            chat.creatorID = ID(info["creator"] as? String ?? "")
            chat.createdOn = Date(timeIntervalSince1970: (info["created:on"] as? Double ?? 0) / 1000)
            
            chatMessagesRef.observeSingleEvent(of: .value, with: { snapshot in
                guard snapshot.exists() else {
                    getChatTitleBlock(chat, chatCounterUpdate)
                    return
                }
                
                getRecentChatMessageBlock(chat, chatCounterUpdate)
                
            }) { _ in
                getChatTitleBlock(chat, chatCounterUpdate)
            }
            
        }) { _ in
            chatCounterUpdate(nil)
        }
    }
    
    private func getRecentChatMessage(_ chat: Chat, _ chatCounterUpdate: @escaping (Chat?) -> Void) {
        let getChatTitleBlock = getChatTitle
        
        let _ = recentChatMessageQuery.getRecentChatMessage(of: chat.id) { result in
            switch result {
            case .ok(let message):
                var chat = chat
                chat.recent = message
                getChatTitleBlock(chat, chatCounterUpdate)
                
            case .err:
                chatCounterUpdate(nil)
            }
        }
    }
    
    private func getChatTitle(_ chat: Chat, _ chatCounterUpdate: @escaping (Chat?) -> Void) {
        let authUserID = meID
        let chatTitleRef = database.reference().child("chat:participant:title/\(chat.id)/\(authUserID)")
        
        chatTitleRef.observeSingleEvent(of: .value, with: { snapshot in
            var chat = chat
            
            if snapshot.exists(), let title = snapshot.value as? String, !title.isEmpty {
                chat.title = title
            }
            
            chatCounterUpdate(chat)
            
        }) { _ in
            chatCounterUpdate(nil)
        }
    }

}
