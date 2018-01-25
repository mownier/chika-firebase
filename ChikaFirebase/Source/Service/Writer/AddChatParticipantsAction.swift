//
//  AddChatParticipantsAction.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/18/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class AddChatParticipantsAction: ChikaCore.AddChatParticipantsAction {

    var database: Database
    
    public init(database: Database = Database.database()) {
        self.database = database
    }
    
    public func addChatParticipants(withPersonIDs personIDs: [ID], chatID: ID, completion: @escaping (Result<OK>) -> Void) -> Bool {
        guard !"\(chatID)".isEmpty else {
            completion(.err(Error("chat ID is empty")))
            return false
        }
        
        guard !personIDs.isEmpty else {
            completion(.err(Error("no person IDs")))
            return false
        }
        
        var nonParticipantIDs: [ID] = []
        var nonParticipantIDCounter: UInt = 0 {
            didSet {
                guard personIDs.count == nonParticipantIDCounter else {
                    return
                }
                
                guard !nonParticipantIDs.isEmpty else {
                    completion(.err(Error("no participants added, either you are not a participant of the conversation or you don't have permission to add participants")))
                    return
                }
                
                guard personIDs.sorted(by: { "\($0)" < "\($1)" }) == nonParticipantIDs.sorted(by: { "\($0)" < "\($1)" }) else {
                    completion(.err(Error("there are participants who are non-existing or already added")))
                    return
                }
                
                updateChildValues(nonParticipantIDs, chatID, completion)
            }
        }
        
        for personID in personIDs {
            isNonParticipant(personID, chatID) { nonParticipantID in
                if let id = nonParticipantID, !"\(id)".isEmpty {
                    nonParticipantIDs.append(id)
                }
                nonParticipantIDCounter += 1
            }
        }

        return true
    }
    
    private func isNonParticipant(_ personID: ID, _ chatID: ID, _ nonParticipantIDCounterUpdate: @escaping (ID?) -> Void) {
        database.reference().child("chat:participants/\(chatID)/\(personID)").observeSingleEvent(of: .value, with: { snapshot in
            guard !snapshot.exists() else {
                nonParticipantIDCounterUpdate(nil)
                return
            }
            
            nonParticipantIDCounterUpdate(personID)
            
        }) { error in
            nonParticipantIDCounterUpdate(nil)
        }
    }
    
    private func updateChildValues(_ nonParticipantIDs: [ID], _ chatID: ID, _ completion: @escaping (Result<OK>) -> Void) {
        var values: [String: Any] = [:]
        
        for personID in nonParticipantIDs {
            values["person:inbox/\(personID)/\(chatID)"] = true
            values["chat:participants/\(chatID)/\(personID)"] = true
        }
        
        database.reference().updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("added participants successfully")))
        }
    }
    
}
