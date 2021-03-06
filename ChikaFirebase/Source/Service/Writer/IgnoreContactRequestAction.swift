//
//  IgnoreContactRequestAction.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 1/19/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class IgnoreContactRequestAction: ChikaCore.IgnoreContactRequestAction {

    var meID: String
    var database: Database
    
    public init(meID: String = FirebaseCommunity.Auth.auth().currentUser?.uid ?? "", database: Database = Database.database()) {
        self.meID = meID
        self.database = database
    }
    
    public func ignoreContactRequest(withID id: ID, completion: @escaping (Result<OK>) -> Void) -> Bool {
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        guard !"\(id)".isEmpty else {
            completion(.err(Error("contact request ID is empty")))
            return false
        }
        
        let updateRootChildValuesBlock = updateRootChildValues
        
        getRequestorID(id) { result in
            switch result {
            case .ok(let requestorID):
                updateRootChildValuesBlock(id, requestorID, completion)
                
            case .err(let error):
                completion(.err(error))
            }
        }
        
        return true
    }
    
    private func updateRootChildValues(_ contactRequestID: ID, _ requestorID: ID, _ completion: @escaping (Result<OK>) -> Void) {
        guard requestorID != ID(meID) else {
            completion(.err(Error("can not ignore the request because you are the requestor")))
            return
        }
        
        let rootRef = database.reference()
        let values: [String: Any] = [
            "contact:requests/\(contactRequestID)": NSNull(),
            "person:contact:request:established/\(requestorID)/\(meID)": NSNull(),
            "person:contact:request:established/\(meID)/\(requestorID)": NSNull()
        ]
        
        rootRef.updateChildValues(values) { error, _ in
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            completion(.ok(OK("ignored contact request successfully")))
        }
    }
    
    private func getRequestorID(_ id: ID, _ completion: @escaping (Result<ID>) -> Void) {
        let requestorRef = database.reference().child("contact:requests/\(id)/requestor")
        requestorRef.observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.exists(), let requestor = snapshot.value as? String, !requestor.isEmpty else {
                completion(.err(Error("requestor not found")))
                return
            }
            
            completion(.ok(ID(requestor)))
            
        }) { error in
            completion(.err(error))
        }
    }
    
}
