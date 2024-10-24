import AMSMB2

class SMBClient {
    /// connect to: `smb://guest@XXX.XXX.XX.XX/share`
    
    let serverURL: URL
    let credential: URLCredential
    let share: String
    
    lazy private var client = AMSMB2(url: self.serverURL, credential: self.credential)!
    
    init(url: String, share: String, user: String, password: String) {
        serverURL = URL(string: url)!
        self.share = share
        credential = URLCredential(user: user, password: password, persistence: URLCredential.Persistence.forSession)
    }
    
    private func connect(handler: @escaping (Result<AMSMB2, Error>) -> Void) {
        client.connectShare(name: self.share) { error in
            if let error = error {
                handler(.failure(error))
            } else {
                handler(.success(self.client))
            }
        }
    }
    
    func listDirectory(path: String, handler: @escaping (Result<[String], Error>) -> Void) {
        connect { result in
            switch result {
            case .success(let client):
                client.contentsOfDirectory(atPath: path) { result in
                    switch result {
                    case .success(let files):
                        var shares: [String] = []
                        for entry in files {
                            let fileType: URLFileResourceType = entry[.fileResourceTypeKey] as! URLFileResourceType
                            var rawName: String = entry[.pathKey] as! String
                            if (fileType == URLFileResourceType.directory) {
                              rawName += "/"
                            }
                            
                            shares.append(self.serverURL.absoluteString + "/" + rawName)
                        }
                        
                        handler(.success(shares))
                        
                    case .failure(let error):
                        handler(.failure(error))
                    }
                }
                
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
    
    func downloadFile(atPath: String, to: String, handler: @escaping (Result<String, Error>) -> Void) {
        connect { result in
            switch result {
            case .success(let client):
                client.downloadItem(atPath: atPath, to: URL(fileURLWithPath: to)) { bytes, total in
                    return true
                } completionHandler: { error in
                    switch error {
                    case .some(let error):
                        handler(.failure(error))
                        
                    case .none:
                        handler(.success(to))
                    }
                }
                
            case .failure(let error):
                print(error)
                handler(.failure(error))
            }
        }
    }
    
    // Add upload file functionality
   func uploadFile(from localPath: String, to remotePath: String, handler: @escaping (Result<String, Error>) -> Void) {
        
        var filePath : String =  localPath
//         if filePath.hasPrefix("/") {
//     filePath.remove(at: filePath.startIndex)
// }
        print("local path when upload is : \(filePath)")
        guard let localURL = URL(string: filePath) else {
            handler(.failure(NSError(domain: "Invalid local file path", code: 1, userInfo: nil)))
            return
        }
        let fileUrl = URL(fileURLWithPath: filePath)
        connect { result in
            switch result {
            case .success(let client):
                client.uploadItem(at: fileUrl, toPath: remotePath, progress: { bytesSent in
                    // Optionally track the progress of the upload
                    return true // Continue uploading
                }, completionHandler: { error in
                    if let error = error {
                        print("error localURL \(localURL) remotePath \(remotePath) ")
                        handler(.failure(error))
                    } else {
                        handler(.success("File uploaded to \(remotePath)"))
                    }
                })
                
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}
