//
//  FindDeviceModel.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/5/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI
import Combine

enum CameraDiscoveryStatus: String {
    case NotFound = "Connect via..."
    case QRCodeFound = "Connecting..."
    case WiFiConnected = "Finding Camera..."
    case CameraFound = "Connected."
}

class FindDeviceModel: BindableObject {
    let willChange = PassthroughSubject<FindDeviceModel, Never>()
    
    var cameraDiscoverStatus = CameraDiscoveryStatus.NotFound {
        didSet {
            willChange.send(self)
        }
    }
    
    init() {
        CameraWrapper.shared.delegate = self
    }
}

extension FindDeviceModel {
    func findCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            CameraWrapper.shared.startDiscovery()
        }
    }
    }

extension FindDeviceModel: CameraAPIDelegate {
    func errorDidThrow(_ err: CameraAPIError) {
        print(err)
    }
    
    func cameraDidDiscovery(_ cameraAddress: String) {
        self.cameraDiscoverStatus = .CameraFound
        CameraDescription.CameraLocation = cameraAddress
    }
}

extension FindDeviceModel: QRCodeScannerDelegate {
    func codeDidFind(_ code: String) {
        cameraDiscoverStatus = .QRCodeFound
        
        let wifi = parseQRCode(code)
        
        connectToWifi(wifi) { connected in
            if connected {
                self.cameraDiscoverStatus = .WiFiConnected
                self.findCamera()
            } else {
                self.cameraDiscoverStatus = .NotFound
            }
        }
    }
}
