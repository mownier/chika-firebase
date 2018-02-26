//
//  ImageUploader.swift
//  ChikaFirebase
//
//  Created by Mounir Ybanez on 2/21/18.
//  Copyright © 2018 Nir. All rights reserved.
//

import ChikaCore
import FirebaseCommunity

public class ImageUploader: ChikaCore.ImageUploader, Cancelable, Resumable, Pauseable {
    
    var meID: String
    var storage: Storage
    
    var task: StorageUploadTask?
    
    public let style: Style
    
    public init(meID: String, storage: Storage, style: Style) {
        self.meID = meID
        self.style = style
        self.storage = storage
    }
    
    public convenience init(style: Style) {
        self.init(
            meID: FirebaseCommunity.Auth.auth().currentUser?.uid ?? "",
            storage: Storage.storage(),
            style: style
        )
    }
    
    @discardableResult
    public func uploadImage(_ image: UIImage, onProgress: ((Progress?) -> Void)?, completion: @escaping (Result<URL>) -> Void) -> Bool {
        guard task == nil else {
            completion(.err(Error("currently uploading an image")))
            return false
        }
        
        guard !meID.isEmpty else {
            completion(.err(Error("current user ID is empty")))
            return false
        }
        
        guard let imageData = UIImagePNGRepresentation(image) else {
            completion(.err(Error("can not covert UIImage to data")))
            return false
        }
        
        let uploaderID = ID(meID)
        
        let path = style.createPath(withUploaderID: uploaderID)
        let metadata = style.createMetadata(withUploaderID: uploaderID)
        
        task = storage.reference().child(path).putData(imageData, metadata: metadata) { [weak self] metadata, error in
            defer {
                self?.task = nil
            }
            
            guard error == nil else {
                completion(.err(error!))
                return
            }
            
            guard let url = metadata?.downloadURL() else {
                completion(.err(Error("download URL not created")))
                return
            }
            
            completion(.ok(url))
        }
        
        task?.observe(.progress) { snapshot in
            onProgress?(snapshot.progress)
        }

        return true
    }
    
    @discardableResult
    public func cancel() -> Bool {
        guard task != nil else {
            return false
        }
        
        task?.cancel()
        return true
    }
    
    @discardableResult
    public func resume() -> Bool {
        guard task != nil else {
            return false
        }
        
        task?.resume()
        return true
    }
    
    @discardableResult
    public func pause() -> Bool {
        guard task != nil else {
            return false
        }
        
        task?.pause()
        return true
    }
    
    public enum Style {
        
        case personAvatar
        case chatAvatar(ID)
        case chatMessagePhoto(ID)
        
        func createPath(withUploaderID id: ID) -> String {
            switch self {
            case .personAvatar:
                return "/persons/\(id)/avatar.png"
                
            case .chatAvatar(let chatID):
                return "/chats/\(chatID)/avatar.png"
                
            case .chatMessagePhoto(let chatID):
                let key = Date().timeIntervalSinceReferenceDate * 1000
                return "/chats/\(chatID)/images/\(key).png"
            }
        }
        
        func createMetadata(withUploaderID id: ID) -> StorageMetadata? {
            var info: [String: Any] = [
                "uploader": "\(id)"
            ]
            
            switch self {
            case .personAvatar:
                info["owner"] = "\(id)"
                
            case .chatAvatar(let chatID),
                 .chatMessagePhoto(let chatID):
                info["chat"] = "\(chatID)"
            }
            
            let metadata = StorageMetadata(dictionary: info)
            metadata?.contentType = "image/png"
            
            return metadata
        }
        
    }
    
}
