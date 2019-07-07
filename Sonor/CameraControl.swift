//
//  CameraControl.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/5/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import AVFoundation
import SwiftUI
import UIKit

struct CameraControl : UIViewControllerRepresentable {
    @EnvironmentObject var state: GlobalStore
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    func makeCoordinator() ->  {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageViewController.dataSource = context.coordinator
        return pageViewController
    }

    
    class Coordinator: NSObject, UIPageViewControllerDataSource {
        var parent: UIPageViewController
        
        init(_ pageViewController: CameraControl) {
            self.parent = pageViewController
        }
    }
    
    private func scanQR() {
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
           videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession?.canAddInput(videoInput)) {
            captureSession?.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, , queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
    }
    
    private func failed() {


    }
}

#if DEBUG
struct CameraControl_Previews : PreviewProvider {
    static var previews: some View {
        CameraControl()
    }
}
#endif
