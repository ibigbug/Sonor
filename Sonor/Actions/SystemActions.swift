//
//  SystemActions.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/28/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import Foundation
import NetworkExtension

func connectToWifi(_ wifi: WifiInfo, completion: @escaping (Bool) -> Void)  {
    let hotspotConfig = NEHotspotConfiguration(ssid: wifi.ssid, passphrase: wifi.passphase, isWEP: false)
    NEHotspotConfigurationManager.shared.apply(hotspotConfig) {(error) in
        if error != nil {
            completion(false)
        } else {
            completion(true)
        }
    }
}
