//
//  Camera.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/3/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import Foundation
import CameraAPI

protocol CameraAPIDelegate: AnyObject {
    func cameraDidDiscovery(_ cameraAddress: String)
}

class CameraWrapper {
    
    static let shared = CameraWrapper()
    
    weak var delegate: CameraAPIDelegate?
    
    private var cameraAddress: String?
    
    private init() {
        guard let p = CameraDiscovery() else { return }
        guard let s = String(bytesNoCopy: p, length: strlen(p), encoding: .utf8, freeWhenDone: true) else { return }
        self.cameraAddress = s
    }
    
    public func startDiscovery() {
        guard let s = self.cameraAddress else { return }
        if s != "" {
            delegate?.cameraDidDiscovery(s)
            deviceDescription(s)
        }
    }
    
    public func deviceDescription(_ cameraAddr: String) {
        guard let p = DeviceDescription(UnsafeMutablePointer(mutating: cameraAddr)) else { return }
        p.withMemoryRebound(to: DeviceDescription_t.self, capacity: 1){ ptr in
            let desc = ptr.pointee
            guard let u = String(bytesNoCopy: desc.CameraUrl, length: strlen(desc.CameraUrl), encoding: .utf8, freeWhenDone: true) else { return }
            print("CameraUrl \(u)")

        }
    }
}
