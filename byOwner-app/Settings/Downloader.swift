//
//  Downloader.swift
//  byOwner-app
//
//  Created by Ayşegül Koçak on 9.12.2018.
//  Copyright © 2018 Ayşegül Koçak. All rights reserved.
//

import Foundation
import Firebase


let storage = Storage.storage()


func downloadImages(urls: String, withBlock: @escaping (_ image: [UIImage?])->Void) {
    
    let linkArray = separateImageLinks(allLinks: urls)
    var imageArray: [UIImage] = []
    
    var downloadCounter = 0
    
    for link in linkArray {
        
        let url = NSURL(string: link)
        let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
        
        downloadQueue.async {
            
            downloadCounter += 1
            let data = NSData(contentsOf: url! as URL)
            if data != nil {
                imageArray.append(UIImage(data: data! as Data)!)
                if downloadCounter == imageArray.count {
                    DispatchQueue.main.async {
                        withBlock(imageArray)
                    }
                }
            } else {
                print("couldnt download image")
                withBlock(imageArray)
            }
        }
    }
    
}


func uploadImages(images: [UIImage], userId: String, referenceNumber: String, withBlock: @escaping (_ imageLink: String?) -> Void) {
    
    convertImagesToData(images: images) { (pictures) in
        
        var uploadCounter = 0
        var nameSuffix = 0
        
        var linkString = "" // in backendless
        
        for picture in pictures {
            
            let fileName = "PropetyImages/" + userId + "/" + referenceNumber + "/image" + "\(nameSuffix)" + ".jpg"
            
            nameSuffix += 1

            let storageRef = storage.reference(forURL: kFILEREFERENCE).child(fileName)
            
            var task: StorageUploadTask!
  
            task = storageRef.putData(picture, metadata: nil, completion: { (metadata, error) in
                
                uploadCounter += 1
                
                if error != nil {
                    return
                }
                
                let link = metadata!.downloadURL() // this way we are getting to the link to where our firebase has saved our image so we can download it later on.
                
                linkString = linkString + link!.absoluteString + ","
                
                if uploadCounter == pictures.count {
                    task.removeAllObservers()
                    withBlock(linkString)
                    
                }
            })
        }
    }
}


//MARK: Helpers

func convertImagesToData(images: [UIImage], withBlock: @escaping (_ datas: [Data])->Void) {
    
    var dataArray: [Data] = []
    
    for image in images {
        dataArray.append(UIImageJPEGRepresentation(image, 0.5)!)
    }
    
    withBlock(dataArray)
    
}

func separateImageLinks(allLinks: String) -> [String] {
    
    var linkArray = allLinks.components(separatedBy: ",")
    linkArray.removeLast()
    
    return linkArray
}
