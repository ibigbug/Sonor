//
//  Camera.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/3/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import Foundation
import CameraAPI

@objc protocol CameraAPIDelegate: AnyObject {
    func cameraDidDiscovery(_ cameraAddress: String)
    @objc optional func availableApiDidLoad(_ apiList: [String])
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
            CameraDescription.CameraApiUrl = String(bytesNoCopy: desc.CameraUrl, length: strlen(desc.CameraUrl), encoding: .utf8, freeWhenDone: false)
            
            CameraDescription.AccessControlApiUrl = String(bytesNoCopy: desc.AccessControlUrl, length: strlen(desc.AccessControlUrl), encoding: .utf8, freeWhenDone: false)
            
            CameraDescription.GuideApiUrl = String(bytesNoCopy: desc.GuideUrl, length: strlen(desc.GuideUrl), encoding: .utf8, freeWhenDone: false)
            
            CameraDescription.SystemApiUrl = String(bytesNoCopy: desc.SystemUrl, length: strlen(desc.SystemUrl), encoding: .utf8, freeWhenDone: false)
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
                self.delegate?.availableApiDidLoad?(apiList.compactMap{$0})
            }
        }
    }
}
