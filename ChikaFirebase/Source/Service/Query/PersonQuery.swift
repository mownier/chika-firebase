//
//  PersonQuery.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/12/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class PersonQuery: ChikaCore.PersonQuery {
    
    var database: Database
    
    public init(database: Database = Database.database()) {
        self.database = database
    }
    
    public func getPersons(for personIDs: [ID], completion: @escaping (Result<[Person]>) -> Void) -> Bool {
        let personIDs = personIDs.filter({ !"\($0)".isEmpty })
        
        guard !personIDs.isEmpty else {
            completion(.err(Error("empty personIDs")))
            return false
        }
        
        var persons: [Person] = []
        var personCounter: UInt = 0 {
            didSet {
                guard personCounter == personIDs.count else {
                    return
                }
                
                completion(.ok(persons))
            }
        }
        
        for personID in personIDs {
            getPersonInfo(personID, completion) { person in
                if person != nil  {
                    persons.append(person!)
                }
                personCounter += 1
            }
        }
        
        return true
    }
    
    private func getPersonInfo(_ personID: ID, _ completion: @escaping (Result<[Person]>) -> Void, _ personCounterUpdate: @escaping (Person?) -> Void) {
        let personsRef = database.reference().child("persons/\(personID)")
        
        personsRef.observeSingleEvent(of: .value) { snapshot in
            guard let info = snapshot.value as? [String: Any] else {
                personCounterUpdate(nil)
                return
            }
            
            var person = Person()
            person.id = personID
            person.name = info["name"] as? String ?? ""
            person.avatarURL = info["avatar:url"] as? String ?? ""
            person.displayName = info["display:name"] as? String ?? ""
            
            personCounterUpdate(person)
        }
    }
}
