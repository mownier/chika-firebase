//
//  OnlinePresenceSwitcher.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/19/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class OnlinePresenceSwitcher: ChikaCore.OnlinePresenceSwitcher {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func switchToOnline(withCompletion completion: @escaping (Result<OK>) -> Void) -> Bool {
        let rootRef = database.reference()
        let connectedRef = rootRef.child(".info/connected")
        let meID = self.meID
        
        connectedRef.observe(.value, with: { snapshot in
            guard let connected = snapshot.value as? Bool, connected else {
                completion(.err(Error("not connected")))
                return
            }
            
            let presenceRef = rootRef.child("person:presence/\(meID)")
            presenceRef.onDisconnectSetValue(["is:active": false, "active:on": ServerValue.timestamp()])
            presenceRef.setValue(["is:active": true, "active:on": ServerValue.timestamp()])
            
            completion(.ok(OK("switched presence to online")))
            
        }) { error in
            completion(.err(error))
        }
        
        return true
    }
    
}
