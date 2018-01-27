//
//  NameUpdater.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/26/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class NameUpdater: ChikaCore.NameUpdater {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func updateName(withNewValue newName: String, completion: @escaping (Result<OK>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        guard !newName.isEmpty else {
            completion(.err(Error("new name is empty")))
            return false
        }
        
        let query = database.reference().child("name:person").queryOrderedByValue().queryEqual(toValue: meID)
        let handleSnapshotBlock = handleSnapshot
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            handleSnapshotBlock(snapshot, newName, completion)
            
        }) { error in
            completion(.err(error))
        }
        
        return true
    }
    
    private func handleSnapshot(_ snapshot: DataSnapshot, _ newName: String, _ completion: @escaping (Result<OK>) -> Void) {
        var ok = false
        var currentName = ""
        
        if !snapshot.exists() {
            ok = true
            
        } else {
            var personKey = ""
            let value = snapshot.value as? [String: String] ?? [:]
            let filtered = value.filter({ ID($0.value) == ID(meID) })
            if filtered.keys.count == 1 {
                currentName = filtered.keys.first!
                if filtered[currentName] != nil {
                    personKey = filtered[currentName]!
                }
            }
            ok = !personKey.isEmpty && ID(personKey) == ID(meID)
        }
        
        guard ok else {
            completion(.err(Error("name already taken")))
            return
        }
        
        updateChildValues(currentName, newName, completion)
    }
    
    private func updateChildValues(_ currentName: String, _ newName: String, _ completion: @escaping (Result<OK>) -> Void) {
        var values: [String: Any] = [
            "persons/\(meID)/name": newName,
            "name:person/\(newName)": "\(meID)",
            "person:search/\(meID)/name": newName.lowercased()
        ]
        
        if !currentName.isEmpty && currentName != newName {
            values["name:person/\(currentName)"] = NSNull()
        }
        
        database.reference().updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("updated person successfully")))
        }
    }
    
}
