//
//  Camera.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/3/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import Foundation
import CameraAPI
import Alamofire

enum CameraAPIError: Error {
    case generalError(errorMessage: String)
    case invalidResponse
}

protocol CameraAPIDelegate: AnyObject {
    func cameraDidDiscovery(_ cameraAddress: String)
    func errorDidThrow(_ err: CameraAPIError)
}

extension CameraAPIDelegate {
    func availableApiDidLoad(_ apiList: [String]) {}
    func pictureDidTake(_ pictureUrl: String) {}
    func pictureDidSave(_ pictureLocalPath: String) {}
}

class CameraWrapper {
    
    static let shared = CameraWrapper()
    
    weak var delegate: CameraAPIDelegate?
    
    private init() {}
    
    public func startDiscovery() {
        guard let p = CameraDiscovery() else { return }
        guard let s = String(bytesNoCopy: p, length: strlen(p), encoding: .utf8, freeWhenDone: true) else { return }
        CameraDescription.CameraLocation = s
        deviceDescription(s)
        DispatchQueue.main.async {
            self.delegate?.cameraDidDiscovery(s)
        }
    }
    
    public func deviceDescription(_ cameraAddr: String) {
        guard let p = DeviceDescription(UnsafeMutablePointer(mutating: cameraAddr)) else { return }
        p.withMemoryRebound(to: DeviceDescription_t.self, capacity: 1){ ptr in
            let desc = ptr.pointee
            CameraDescription.CameraApiUrl = String(bytesNoCopy: desc.CameraUrl, length: strlen(desc.CameraUrl), encoding: .utf8, freeWhenDone: true)
            
            CameraDescription.AccessControlApiUrl = String(bytesNoCopy: desc.AccessControlUrl, length: strlen(desc.AccessControlUrl), encoding: .utf8, freeWhenDone: true)
            
            CameraDescription.GuideApiUrl = String(bytesNoCopy: desc.GuideUrl, length: strlen(desc.GuideUrl), encoding: .utf8, freeWhenDone: true)
            
            CameraDescription.SystemApiUrl = String(bytesNoCopy: desc.SystemUrl, length: strlen(desc.SystemUrl), encoding: .utf8, freeWhenDone: true)
        }
    }
    
    public func loadAvailableApiList() {
        guard let aSlice = GetAvailableApiList(UnsafeMutablePointer(mutating: CameraDescription.CameraApiUrl)) else { return }
        
        aSlice.withMemoryRebound(to: SliceHeader_t.self, capacity: 1) { ptr in
            let slice = ptr.pointee
            let orig = Array(UnsafeBufferPointer(start: slice.Data, count: (Int)(slice.Len)))
            let filtered = orig.compactMap{$0}
            let apiList = filtered.map({String(bytesNoCopy: $0, length: strlen($0), encoding: .utf8, freeWhenDone: true)})
            
            DispatchQueue.main.async {
                self.delegate?.availableApiDidLoad(apiList.compactMap{$0})
            }
        }
    }
    
    func actTakePicture(completion: @escaping (String) -> Void ) {
        guard let cameraAPI = CameraDescription.CameraApiUrl else { return }
        let payload: [String: Any] = [
            "id": 1,
            "version": "1.0",
            "params": [],
            "method": "actTakePicture"
        ]
        
        AF.request(cameraAPI, method: HTTPMethod.post, parameters: payload, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .failure(let error):
                    self.delegate?.errorDidThrow(.generalError(errorMessage: error.localizedDescription))
                    return
                    
                case .success(let data):
                    guard let json = data as? [String: Any] else {
                        self.delegate?.errorDidThrow(.invalidResponse)
                        return
                    }
                    
                    guard let result = json["result"] as? [[String]] else {
                        self.delegate?.errorDidThrow(.invalidResponse)
                        return
                    }
                    
                    self.delegate?.pictureDidTake(result[0][0])
                    
                    guard let url = URL(string: result[0][0]) else { return }
                    DispatchQueue.global().async {
                        guard let data = try? Data(contentsOf: url) else { return }
                        guard let image = UIImage(data: data) else { return }
                        let localUrl = saveImage(image)
                        
                        DispatchQueue.main.async {
                            completion(localUrl)
                        }
                    }
                }
            }
    }
}

func getDirectoryPath() -> String {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0].path
}

fileprivate func directoryExists(_ path: String) -> Bool {
    var isDirectory = ObjCBool(true)
    let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDirectory)
    return exists && isDirectory.boolValue
}

func saveImage(_ image: UIImage) -> String {
    let fileManager = FileManager.default
    let localImagePath = (getDirectoryPath() as NSString).appendingPathComponent("DCIM/\(Date()).jpeg")
    guard let imageData = image.jpegData(compressionQuality: 1) else { return "" }
    fileManager.createFile(atPath: localImagePath, contents: imageData, attributes: nil)
    return localImagePath
}

func getGalleryRootDirectory() -> String {
    let dir = (getDirectoryPath() as NSString).appendingPathComponent("DCIM")
    if !directoryExists(dir) {
        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("failed to create gallery folder")
        }
    }
    return dir
}
