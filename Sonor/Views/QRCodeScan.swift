//
//  QRCodeScan.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/25/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

struct QRCodeScan: UIViewControllerRepresentable {
    
    @ObservedObject var state: FindDeviceModel
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> QRCodeScanVC {
        let vc = QRCodeScanVC()
        vc.delegate = context.coordinator
        return vc
    }
    
    func updateUIViewController(_ vc: QRCodeScanVC, context: Context) {
    }

    class Coordinator: NSObject, QRCodeScannerDelegate {
        
        func codeDidFind(_ code: String) {
            parent.state.codeDidFind(code)
        }
        
        var parent: QRCodeScan
        
        init(_ parent: QRCodeScan) {
            self.parent = parent
        }
    }
}
