//
//  TestUIControl.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/4/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct TestUIControl : UIViewRepresentable {
    @Binding var cameraAddress: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UIButton {
        let control = UIButton()
        
        CameraWrapper.shared.delegate = context.coordinator
        
        DispatchQueue.global(qos: .userInitiated).async {
            CameraWrapper.shared.startDiscovery()
        }

        return control
    }
    
    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.setTitle(cameraAddress, for: .normal)
    }
    
    class Coordinator: NSObject, CameraAPIDelegate {
        var control: TestUIControl
        
        init(_ control: TestUIControl) {
            self.control = control
            super.init()
        }
        
        func cameraDidDiscovery(_ cameraAddress: String) {
            control.cameraAddress = cameraAddress
        }
    }
}
