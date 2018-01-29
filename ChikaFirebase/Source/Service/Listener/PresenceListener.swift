//
//  PresenceListener.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/28/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class PresenceListener: ChikaCore.PresenceListener {

    var meID: String
    var database: Database
    
    var handles: [ID: UInt]
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
        
        self.handles = [:]
    }
    
    public func stopAll() -> Bool {
        guard !handles.isEmpty else {
            return false
        }
        
        let ok = handles.flatMap({ stopListening(on: $0.key ) }).reduce(true, { $0 && $1 })
        return ok
    }
    
    public func stopListening(on personID: ID) -> Bool {
        guard let handle = handles[personID] else {
            return false
        }
        
        let presenceRef = database.reference().child("person:presence/\(personID)")
        presenceRef.removeObserver(withHandle: handle)
        handles.removeValue(forKey: personID)
        
        return true
    }
    
    public func startListening(on personID: ID, callback: @escaping (Result<Presence>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            callback(.err(Error("current user ID is empty")))
            return false
        }
        
        guard !"\(personID)".isEmpty else {
            callback(.err(Error("person ID is empty")))
            return false
        }
        
        guard personID != ID(meID) else {
            callback(.err(Error("you are not allowed to listen on your own presence")))
            return false
        }
        
        let presenceRef = database.reference().child("person:presence/\(personID)")
        let handle = presenceRef.observe(.value, with: { snapshot in
            guard snapshot.exists() else {
                callback(.err(Error("can not get info of the person's presence")))
                return
            }
            
            var presence = Presence()
            presence.personID = personID
            presence.isActive = snapshot.childSnapshot(forPath: "is:active").value as? Bool ?? false
            presence.activeOn = Date(timeIntervalSince1970: (snapshot.childSnapshot(forPath: "active:on").value as? Double ?? 0) / 1000)
            
            callback(.ok(presence))
            
        }) { error in
            callback(.err(error))
        }
        
        handles[personID] = handle
        
        return true
    }
    
}
