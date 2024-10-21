import Flutter
import UIKit
import AMSMB2

public class SwiftSambaBrowserPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "samba_browser", binaryMessenger: registrar.messenger())
        let instance = SwiftSambaBrowserPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! [String:Any]
        
        switch call.method {
        case "getShareList":
            getShareList(args: args, flutterResult: result)
            break
            
        case "saveFile":
            saveFile(args: args, flutterResult: result)
            break
        case "uploadFile":
            uploadFile(args: args, flutterResult: result)
            break
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func getShareList(args: [String:Any], flutterResult: @escaping FlutterResult) {
        
        // extract the first part of the URL to connect to the root-subfolder
        let url: String = "smb://" + Array((args["url"] as! String).split(separator: "/"))[1..<3].joined(separator: "/")

        // the last component of the url has to be extracted separately as the share string must not be empty
        let share: String = String(url.split(separator: "/").last!)
        let path: String = (args["url"] as! String).components(separatedBy: "/").dropFirst(4).joined(separator: "/")
        
        
        let user: String = args["username"] as! String
        let password: String = args["password"] as! String
        
        SMBClient(url: url, share: share, user: user, password: password).listDirectory(path: path, handler: { result in
            switch result {
            case .success(let shares):
                flutterResult(shares)
            case .failure(let error):
                flutterResult(FlutterError(code: "An error occurred", message: error.localizedDescription, details: nil))
            }
        })
    }
    
    private func saveFile(args: [String:Any], flutterResult: @escaping FlutterResult) {
        
        // extract the first part of the URL to connect to the root-subfolder
        let url: String = "smb://" + Array((args["url"] as! String).split(separator: "/"))[1..<3].joined(separator: "/")
        
        let share: String = String(url.split(separator: "/").last!)
        let atPath: String = String((args["url"] as! String).replacingOccurrences(of: url, with: "").dropFirst())

        let saveFolder: String = args["saveFolder"] as! String
        let fileName: String = args["fileName"] as! String
        let user: String = args["username"] as! String
        let password: String = args["password"] as! String
        
        SMBClient(url: url, share: share, user: user, password: password).downloadFile(atPath: atPath, to: saveFolder + fileName, handler: { result in
            switch result {
            case .success(let shares):
                print("File downloaded successfully")
                flutterResult(shares)
            case .failure(let error):
                print(error)
                flutterResult(FlutterError(code: "An error occurred", message: error.localizedDescription, details: nil))
            }
        })
    }

     // Add upload file functionality
   private func uploadFile(args: [String: Any], flutterResult: @escaping FlutterResult) {
    let url: String = "smb://" + Array((args["url"] as! String).split(separator: "/"))[1..<3].joined(separator: "/") + "/" 
    let share: String = String(url.split(separator: "/").last!)
    let localFilePath: String = args["fileName"] as! String
    let remotePath: String = "smb://" + Array((args["url"] as! String).split(separator: "/"))[1..<3].joined(separator: "/") + "/" 
    // + String(localFilePath.split(separator: "/").last!)
    
    let user: String = args["username"] as! String
    let password: String = args["password"] as! String
    
    // Convert the local file path to a proper file URL
    // let localFileURL = URL(fileURLWithPath: localFilePath)


    // Check if the file exists at the specified local path
        if FileManager.default.fileExists(atPath: localFilePath) {
            print("File exists")
            print("remotePath : \(remotePath)")
            print("url : \(url)")
            print("share : \(share)")
        } else {
            print("File not found at path: \(localFilePath)")
            print("remotePath : \(remotePath)")
            print("url : \(url)")
            print("share : \(share)")
        }


    // Proceed with the upload using the valid file URL
    SMBClient(url: url, share: share, user: user, password: password).uploadFile(from: localFilePath, to: remotePath, handler: { result in
        switch result {
        case .success(let message):
            flutterResult(message)
        case .failure(let error):
            flutterResult(FlutterError(code: "UploadError", message: error.localizedDescription, details: nil))
        }
    })
}

    
}
