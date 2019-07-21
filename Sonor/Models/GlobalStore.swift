//
//  GlobalStore.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/5/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI
import Combine

class GlobalStore: BindableObject {
    var cameraFound = false {
        didSet {
            didChange.send(self)
        }
    }
    var availableApiList: [String] = [] {
        didSet {
            didChange.send(self)
        }
    }
    
    var didChange = PassthroughSubject<GlobalStore, Never>()
    
    init() {
        CameraWrapper.shared.delegate = self
    }
}

extension GlobalStore {
    func findCamera() {
        DispatchQueue.global(qos: .userInitiated).async {
            CameraWrapper.shared.startDiscovery()
        }
    }
    }

extension GlobalStore: CameraAPIDelegate {
    func errorDidThrow(_ err: CameraAPIError) {
        print(err)
    }
    
    func cameraDidDiscovery(_ cameraAddress: String) {
        self.cameraFound = true
        CameraDescription.CameraLocation = cameraAddress
    }
    
    func availableApiDidLoad(_ apiList: [String]) {
        self.availableApiList = apiList
    }
}
