//
//  ViewController.swift
//  dropboxSwiftSDK
//
//  Created by Chad Duffey on 20/05/2015.
//  Copyright (c) 2015 Chad Duffey. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController {

    @IBAction func linkButtonPressed(sender: AnyObject) {
        
        DropboxAuthManager.sharedAuthManager.authorizeFromController(self)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Verify user is logged into Dropbox
        if let token = DropboxAuthManager.sharedAuthManager.getFirstAccessToken() {
            
            // Initialize Dropbox client
            let client = DropboxClient(accessToken: token)
            
            // Get the current user's account info
            client.usersGetCurrentAccount().response { response, error in
                if let account = response {
                    println("Hello \(account.name.givenName)")
                } else {
                    println("Error: \(error!)")
                }
            }
            
            // List folder
            client.filesListFolder(path: "").response { response, error in
                if let result = response {
                    println("Folder contents:")
                    for entry in result.entries {
                        println(entry.name)
                    }
                } else {
                    println("Error: \(error!)")
                }
            }
            
            // Upload a file
            let fileData = "Hello!".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            client.filesUpload(path: "/hello.txt", body: fileData!).response { response, error in
                if let metadata = response {
                    println("Uploaded file name: \(metadata.name)")
                    println("Uploaded file revision: \(metadata.metadata.rev)")
                    
                    // Get file (or folder) metadata
                    client.filesGetMetadata(path: "/hello.txt").response { response, error in
                        if let metadata = response {
                            println("Name: \(metadata.name)")
                            switch metadata.metadata {
                            case .File(let fileInfo):
                                println("This is a file.")
                                println("File size: \(fileInfo.size)")
                            case .Folder(let folderInfo):
                                println("This is a folder.")
                            }
                        } else {
                            println("Error: \(error!)")
                        }
                    }
                    
                    // Download a file
                    client.filesDownload(path: "/hello.txt").response { response, error in
                        if let (metadata, data) = response {
                            println("Dowloaded file name: \(metadata.name)")
                            println("Downloaded file data: \(data)")
                        } else {
                            println("Error: \(error!)")
                        }
                    }
                    
                } else {
                    println("Error: \(error!)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

