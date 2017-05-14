//
//  MediaApi.swift
//  iOS-PartyPlanner
//
//  Created by Bharath D N on 5/4/17.
//  Copyright © 2017 PartyDevs. All rights reserved.
//

// Mark:- Enum
import Foundation
import Firebase

class MediaApi: NSObject {
  
  static let sharedInstance = MediaApi()
  private let mediaStorageRef = FIRStorage.storage().reference().child("media")
  
  // Uploads the media to FireBase and returns the media URL
  func uploadMediaToFireBase(mediaUrl: URL, type: MediaType, filepath: String,
                             success: @escaping (String) -> (), failure: @escaping () -> ())
  {
    let mediaRef = mediaStorageRef.child(filepath)
    
    // TODO: remove user signin before uploading!!! very important
    FIRAuth.auth()?.signIn(withEmail: "u3@gmail.com", password: "qwerty", completion: {
      (user: FIRUser?, error: Error?) in
      if error != nil {
        print("UNable to login")
      } else {
        print("successful login")
        _ = mediaRef.putFile(
          mediaUrl,
          metadata: nil,
          completion: { (metadata, error) in
            if error != nil {
              print("Error Uploading Video!:: \(error?.localizedDescription ?? "oops error")")
              return
            } else {
              print("\nMediaApi:: Media Uploaded! successfully\n")
              let mediaDownloadurl = metadata!.downloadURL()!
              success(mediaDownloadurl.absoluteString)
            }
        })
      }
    })
  }
  
  func uploadFilesToFireBase(mediaUrl: URL,  event: Event, completion: @escaping (Bool) -> ()){
    let filePath  = event.id + UUID().uuidString
    let urlAbsoulteString = mediaUrl.absoluteString
    var mediaType: MediaType = MediaType.video
    if ((urlAbsoulteString.hasSuffix("PNG")) || (urlAbsoulteString.hasSuffix("JPG")) || (urlAbsoulteString.hasSuffix("JPEG"))){
      mediaType = MediaType.image
    }
      
    MediaApi.sharedInstance.uploadMediaToFireBase(mediaUrl: mediaUrl, type: mediaType, filepath: filePath, success: { (downloadUrl : String) in
      print("Upload success", downloadUrl)
      event.postEventPhotoesURL?.append(URL(string: downloadUrl)!)
      completion(true)
    }) {
      print("upload failed")
      completion(false)
    }
  }
}
