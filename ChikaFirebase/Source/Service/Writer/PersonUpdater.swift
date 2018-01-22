//
//  PersonUpdater.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/22/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class PersonUpdater: ChikaCore.PersonUpdater {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func updatePerson(withNewValue person: Person, completion: @escaping (Result<OK>) -> Void) -> Bool {
        var person = person
        person.id = ID(meID)
        
        let rootRef = database.reference()
        let namePersonRef = rootRef.child("person:name")
        let query = namePersonRef.queryOrderedByKey().queryEqual(toValue: person.name)
        
        query.observeSingleEvent(of: .value, with: { snapshot in
            let currentName = snapshot.key
            let personKey = snapshot.value as? String ?? ""
            
            let ok = !snapshot.exists() || (!personKey.isEmpty && ID(personKey) == person.id)
            
            guard ok else {
                completion(.err(Error("name already taken")))
                return
            }
            
            var values: [String: Any] = [
                "persons/\(person.id)/name": person.name,
                "persons/\(person.id)/display:name": person.displayName,
                
                "persons:search/\(person.id)/name": person.name.lowercased(),
                "persons:search/\(person.id)/display:name": person.displayName.lowercased(),
                
                "name:person/\(person.name)": person.id
            ]
            
            if !currentName.isEmpty {
                values["name:person/\(currentName)"] = NSNull()
            }
            
            rootRef.updateChildValues(values) { error, _ in
                guard error == nil else {
                    completion(.err(error!))
                    return
                }
                
                completion(.ok(OK("updated person successfully")))
            }
            
        }) { error in
            completion(.err(error))
        }
        
        return true
    }
}
