//
//  InboxQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class InboxQuery: ChikaCore.InboxQuery {

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
    
    public func getInbox(withCompletion completion: @escaping (Result<[Chat]>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        let inboxRef = database.reference().child("person:inbox/\(meID)")
        let getChatsBlock = getChats
        let getChatIDsBlock = getChatIDs
        
        inboxRef.queryOrdered(byChild: "updated_on").observeSingleEvent(of: .value) { snapshot in
            guard snapshot.exists(), snapshot.childrenCount > 0 else {
                completion(.ok([]))
                return
            }
            
            let chatIDs = getChatIDsBlock(snapshot)
            getChatsBlock(chatIDs, completion)
        }
        
        return true
    }
    
    private func getChatIDs(_ snapshot: DataSnapshot) -> [ID] {
        var chatIDs: [ID] = []
        
        for child in snapshot.children {
            guard let child = child as? DataSnapshot else {
                continue
            }
            
            chatIDs.append(ID(child.key))
        }
        
        return chatIDs
    }
    
    private func getChats(_ chatIDs: [ID], _ completion: @escaping (Result<[Chat]>) -> Void) {
        let _ = chatQuery.getChats(for: chatIDs) { result in
            completion(result)
        }
    }
}
