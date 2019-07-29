//
//  ShootingFeatureRoute.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/5/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

enum SmoothMode: String, CaseIterable {
    case Water = "Water Flow"
    case Twilight = "Twilight Reflection"
    case Silent = "Silent"
    case Smoke = "Smoke Haze"
}

enum SmoothLevel: String, CaseIterable {
    case Low = "Low"
    case Medium = "Medium"
    case High = "High"
}

struct ShootingLongExposure : View {

    @State var smoothMode: SmoothMode = .Water
    @State var smoothLevel: SmoothLevel = .Low
    
    var body: some View {
        NavigationView {
            VStack(alignment:.center) {
                
                LongExposureBackground().scaledToFill()
                    .frame(height: 200)
                    .clipped()

                Form {
                    Section(footer: Text("Scenario Description")) {
                        Picker(selection: $smoothMode, label: Text("Scenario"), content: {
                            ForEach(SmoothMode.allCases, id: \.self) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        })
                    }
                    
                    Section(footer: Text("Smooth Level Description")) {
                        Picker(selection: $smoothLevel, label: Text("Smooth Level")){
                            ForEach(SmoothLevel.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                    }

                    Section {
                        Button(action: {
                            print(self.smoothMode, self.smoothLevel)
                        }) {
                            Text("Start").frame(alignment: .center)
                        }
                    }
                }

                
            }
            .navigationBarTitle("Long Exposure")
            .edgesIgnoringSafeArea(.top)

        }.navigationViewStyle(.stack)
    }
    
    private func shoot() {
        CameraWrapper.shared.actTakePicture(count: 3) { imageUrls in
            let images = imageUrls.map{ UIImage(contentsOfFile: $0) }.compactMap{$0}
            let result = OpenCVWrapper.mergeLongExposure(images)
            _ = saveImage(result)
        }
    }
}

struct LongExposureBackground: View {
    var body: some View {
        Image("long-exposure-bg").resizable()
    }
}

#if DEBUG
struct ShootingLongExposure_Previews : PreviewProvider {
    static var previews: some View {
        ShootingLongExposure()
    }
}
#endif

