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
    case cameraErrorResponse(code: Int, message: String)
}

enum AvailableCameraAPI: String {
    case getEvent = "getEvent"
    case actHalfPressShutter = "actHalfPressShutter"
    case cancelHalfPressShutter = "cancelHalfPressShutter"
    case actTakePicture = "actTakePicture"
    case awaitTakePicture = "awaitTakePicture"
    case getFocusMode = "getFocusMode"
    case setFNumber = "setFNumber"
    case getFNumber = "getFNumber"
    case setShootMode = "setShootMode"
    case getShootMode = "getShootMode"
    case setExposureMode = "setExposureMode"
    case getExposureMode = "getExposureMode"
    case setIsoSpeedRate = "setIsoSpeedRate"
    case getIsoSpeedRate = "getIsoSpeedRate"
    case setWhiteBalance = "setWhiteBalance"
    case getWhiteBalance = "getWhiteBalance"
    case setContShootingMode = "setContShootingMode"
    case getContShootingMode = "getContShootingMode"
    case setIntervalTime = "setIntervalTime"
    case getIntervalTime = "getIntervalTime"
    case getContentCount = "getContentCount"
    case getContentList = "getContentList"
}

enum CameraEvent: String {
    case CameraStatus = "cameraStatus"
    case FocusStatus = "focusStatus"
}

enum FocusStatusParameter: String {
    case NotFocusing = "Not Focusing"
    case Focusing = "Focusing"
    case Focused = "Focused"
    case Failed = "Failed"
}

enum ExposureModeParameter: String {
    case ProgramAuto = "Program Auto"
    case Aperture = "Aperture"
    case Shutter = "Shutter"
    case Manual = "Manual"
    case IntelligentAuto = "Intelligent Auto"
    case SuperiorAuto = "Superior Auto"
}

enum WhiteBalanceModeParameter: String {
    case Auto = "Auto WB"
}

enum CameraStatusParameter: String {
    case IDLE = "IDLE"
}

enum FocusModeParameter: String {
    case AFS = "AF-S"
    case AFC = "AF-C"
    case DMF = "DMF"
    case MF = "MF"
}

enum ContinuousShootingModeParameter: String {
    case Continuous = "Continuous"
}

enum IntervalTimeParameter: String {
    case One = "1"
    case Two = "2"
    case Five = "5"
    case Ten = "10"
    case Thirty = "30"
    case Sixty = "60"
}

protocol CameraAPIDelegate: AnyObject {
    func cameraDidDiscovery(_ cameraAddress: String)
    func errorDidThrow(_ err: CameraAPIError)
}

extension CameraAPIDelegate {
    func pictureDidTake(_ pictureUrl: String) {}
    func pictureDidSave(_ pictureLocalPath: String) {}
}

let ms = 1000
let second = 1000 * ms

class CameraWrapper {
    
    static let shared = CameraWrapper()
    
    weak var delegate: CameraAPIDelegate?
    
    private var focusMode: FocusModeParameter = .MF
    
    private init() {}
    
    public func startDiscovery() {
        let camera = CameraAPICameraDiscovery()
        CameraDescription.CameraLocation = camera
        deviceDescription(camera)
        
        // get camera info
        focusMode = getFocusMode()
        
        DispatchQueue.main.async {
            self.delegate?.cameraDidDiscovery(camera)
        }
    }
    
    private func deviceDescription(_ cameraAddr: String) {
        guard let desc = CameraAPIGetDeviceDescription(cameraAddr) else { return }

        CameraDescription.CameraApiUrl = desc.cameraUrl
        
        CameraDescription.AccessControlApiUrl = desc.accessControlUrl
        
        CameraDescription.GuideApiUrl = desc.guideUrl
        
        CameraDescription.SystemApiUrl = desc.systemUrl
    }
    
    private func sendRequest(_ apiName: AvailableCameraAPI, version: String = "1.0", params: [Any] = [], endpoint: String = "camera", completion: @escaping (DataResponse<Any>) -> Void) {
        guard let cameraLocation = CameraDescription.CameraLocation else { return }
        let payload: [String: Any] = [
            "method": apiName.rawValue,
            "params": params,
            "id": 1,
            "version": version
        ]
        
        AF.request(cameraLocation + endpoint, method: .post, parameters: payload, encoding: JSONEncoding.default)
            .validate(statusCode: 200..<300)
            .responseJSON { completion($0) }
    }
    
    private func sendRequest(_ apiName: AvailableCameraAPI, version: String = "1.0", params: [Any] = [], endpoint: String = "camera") -> DataResponse<Any>? {
        
        let semaphore = DispatchSemaphore(value: 0)
        var rv: DataResponse<Any>? = nil
        sendRequest(apiName, version: version, params: params, endpoint: endpoint) {
            rv = $0
            semaphore.signal()
        }
        semaphore.wait()
        return rv
    }
 
    
    func simpleSend(_ api: AvailableCameraAPI, version: String = "1.0", params: [Any] = []) -> Bool {
        guard let res = sendRequest(api, version: version, params: params) else { return false }
        
        switch res.result {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    func getContentCount() -> Int {
        guard let response = sendRequest(.getContentCount, version: "1.2", params: [
            [
                "uri": "storage:memoryCard1",
                "target": "all",
                "view": "date",
            ]
        ], endpoint: "avContent") else { return 0}
        
        switch response.result {
        case .failure:
            return 0
        case .success(let data):
            guard let json = data as? [String: Any] else { return 0 }
            
            if let result = json["result"] as? [[String: Int]] {
                guard let count = result[0]["count"] else { return 0 }
                return count
            }
            return 0
        }
    }
    
    func getContentList(startIndex: Int, count: Int) -> [String] {
        guard let response = sendRequest(.getContentList, version: "1.3", params: [
            [
                "uri": "storage:memoryCard1",
                "stIdx": startIndex,
                "cnt": count,
                "view": "date",
                "sort": "descending",
                "type": [ "still" ]
            ]
        ], endpoint: "avContent") else { return [] }
        
        switch response.result {
        case .failure:
            return []
        case .success(let data):
            guard let json = data as? [String: Any] else { return [] }
            guard let result = json["result"] as? [[[String: Any]]] else { return [] }
            
            return result[0].map{
                guard let content = $0["coutent"] as? [String: Any] else { return nil }
                guard let original = content["original"] as? [[String: String]] else { return nil }
                guard let url = original[0]["url"] else { return nil }
                return url
            }.compactMap{$0}
        }
    }
    
    func getEvent(query: CameraEvent, blocking: Bool = false) -> String? {
        
        guard let response = sendRequest(.getEvent, version: "1.2", params: [blocking]) else { return nil }

        switch response.result {
        case .failure:
            return nil
        case .success(let data):
            guard let json = data as? [String: Any] else {
                return nil
            }
            
            if let result = json["result"] as? [Any] {
                switch query {
                case .CameraStatus:
                    if let obj = result[1] as? [String:String] {
                        return obj[query.rawValue]
                    }
                case .FocusStatus:
                    if let obj = result[35] as? [String: String] {
                        return obj[query.rawValue]
                    }
                }
            }
        }
        return nil
    }
    
    func actHalfPressShutter() -> Bool {
        guard let response = sendRequest(.actHalfPressShutter) else { return false }
        switch response.result {
        case .failure:
            return false
        case.success(let data):
            guard let json = data as? [String: Any] else {
                return false
            }
            
            if let _ = json["error"] as? [Any] {
                return false
            }
            return true
        }
    }
    
    func cancelHalfPressShutter() -> Bool {
        guard let response = sendRequest(.cancelHalfPressShutter) else { return false }
        switch response.result {
        case .failure:
            return false
        case .success:
            return true
        }
    }
    
    func getFocusMode() -> FocusModeParameter {
        guard let response = sendRequest(.getFocusMode) else {
            return .MF
        }
        switch response.result {
        case .failure:
            return .MF
        case .success(let data):
            guard let json = data as? [String: Any] else {
                return .MF
            }
            
            if let result = json["result"] as? [String] {
                return FocusModeParameter.init(rawValue: result[0])!
            }
        }
        
        return .MF
    }
    
    func actTakePicture(completion: @escaping (String?) -> Void) {

        guard let response = sendRequest(.actTakePicture) else { return }
        
        switch response.result {
        case .failure(let error):
            self.delegate?.errorDidThrow(.generalError(errorMessage: error.localizedDescription))
            completion(nil)
            return
        case .success(let data):
            guard let json = data as? [String: Any] else {
                self.delegate?.errorDidThrow(.invalidResponse)
                completion(nil)
                return
            }
            
            if let err = json["error"] as? [Any] {
                guard let errorCode = err[0] as? Int else {
                    self.delegate?.errorDidThrow(.invalidResponse)
                    completion(nil)
                    return
                }
                guard let errorMessage = err[1] as? String else {
                    self.delegate?.errorDidThrow(.invalidResponse)
                    completion(nil)
                    return
                }
                self.delegate?.errorDidThrow(.cameraErrorResponse(code: errorCode, message: errorMessage))
                completion(nil)
                return
            }
            
            guard let result = json["result"] as? [[String]] else {
                self.delegate?.errorDidThrow(.invalidResponse)
                completion(nil)
                return
            }
            
            self.delegate?.pictureDidTake(result[0][0])
            
            guard let url = URL(string: result[0][0]) else { return }
            DispatchQueue.global().async {
                guard let data = try? Data(contentsOf: url) else { return }
                guard let image = UIImage(data: data) else { return }
                let localUrl = saveImage(image)
                completion(localUrl)
            }
        }
    }
    
    func actTakePicture() -> String? {
        var rv: String?
        let semaphore = DispatchSemaphore(value: 0)
        
        actTakePicture {
            rv = $0
            semaphore.signal()
        }
        
        semaphore.wait()
        return rv
    }
        
    func actTakePicture(count: Int, intervalSec: Int = 1, completion: @escaping ([String]) -> Void) {
        DispatchQueue.global().async {
            if self.focusMode == .AFC || self.focusMode == .AFS {
                _ = self.actHalfPressShutter()
            }
            
            var rv = [String]()
            var taken = 0

            repeat {
                var cameraStatus = ""
                repeat {
                    guard let status = self.getEvent(query: .CameraStatus) else {
                        usleep(useconds_t(5 * second))
                        continue
                    }
                    cameraStatus = status
                } while cameraStatus != CameraStatusParameter.IDLE.rawValue

                let localImage = self.actTakePicture()
                let awaitLocalImage = self.awaitTakePicture()
                _ = self.cancelHalfPressShutter()
                
                guard let realImage = awaitLocalImage?[0] ?? localImage else {
                    usleep(useconds_t(intervalSec * second))
                    continue
                }
                
                rv.append(realImage)
                taken += 1
            } while taken < count
        
            DispatchQueue.main.async {
                completion(rv)
            }
        }
    }
    
    func awaitTakePicture() -> [String]? {
        let status = getEvent(query: .CameraStatus)
        if status == CameraStatusParameter.IDLE.rawValue {
            // Got nothing to do here
            return nil
        }
        
        while true {
            guard let response = sendRequest(.awaitTakePicture) else {
                return nil
            }
            
            switch response.result {
            case .failure:
                return nil
            case .success(let data):
                guard let json = data as? [String: Any] else {
                    return nil
                }

                if let result = json["result"] as? [String] {
                    return result
                } else if let error = json["error"] as? [Any] {
                    guard let code = error[0] as? Int else { return nil }
                    if code == 40403 {
                        continue
                    }
                }
                return nil
            }
        }
    }
}

extension CameraWrapper {
    func setUpCameraSettings(_ settings: CameraSetting) {
        _ = simpleSend(.setFNumber, params: [settings.aperture])
        _ = simpleSend(.setIsoSpeedRate, params: [settings.ISO])
        _ = simpleSend(.setExposureMode, params: [settings.exposureMode.rawValue])
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

func getGalleryRootDirectory() -> NSString {
    let dir = (getDirectoryPath() as NSString).appendingPathComponent("DCIM")
    if !directoryExists(dir) {
        do {
            try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("failed to create gallery folder")
        }
    }
    return dir as NSString
}
