//
//  ShootingFeatureRoute.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/5/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import SwiftUI

let SupportedShotNumbers: [Int] = (0...8).map{(pow(2, $0) as NSDecimalNumber).intValue}

struct ShootingLongExposure : View {

    @ObservedObject var shootingModel: ShootingModel
    @State var smoothMode: ExposureScenario = .WaterFlow
    @State var smoothLevel: SmoothLevel = .Low
    @State var shotNumber: Int = 64
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                
                LongExposureBackground().scaledToFill()
                    .frame(height: 200)
                    .clipped()

                Form {
                    Section(footer: Text("Scenario Description")) {
                        Picker(selection: $smoothMode, label: Text("Scenario"), content: {
                            ForEach(ExposureScenario.allCases, id: \.self) { mode in
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
                        Picker(selection: $shotNumber, label: Text("Shot Number")) {
                            ForEach(SupportedShotNumbers, id: \.self) { num in
                                Text(String(num)).tag(num)
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

        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func shoot() {
        shootingModel.startShooting(shotNumber, scenario: smoothMode)
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
        ShootingLongExposure(shootingModel: ShootingModel())
    }
}
#endif

