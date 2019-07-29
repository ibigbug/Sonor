//
//  QRCodeParser.swift
//  Sonor
//
//  Created by Yuwei Ba on 7/28/19.
//  Copyright © 2019 Watfaq. All rights reserved.
//

import Foundation

// "W01:S:ssid;P:pass;C:model;M:something;"
let kQuickConnectProto = "W01:"
let spliter = #"(?<!\\);"#

struct WifiInfo {
    var S = ""
    var P = ""
    var C = ""
    var M = ""
    
    var ssid: String {
        return "DIRECT-\(S):\(C)"
    }
    
    var passphase: String {
        return P
    }
}

extension StringProtocol {
    func ranges(of string: Self, options: String.CompareOptions = []) -> [Range<Index>] {
        var result: [Range<Index>] = []
        var startIndex = self.startIndex
        while startIndex < endIndex,
            let range = self[startIndex...].range(of: string, options: options) {
                result.append(range)
                startIndex = range.lowerBound < range.upperBound ? range.upperBound :
                    index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return result
    }
}

private func split(_ s: String, by: String) -> [String] {

    let ranges = s.ranges(of: by, options: .regularExpression)
    let cutsStart = ranges.map{ $0.upperBound.utf16Offset(in: s)}
    let cutsEnd = ranges.map{ $0.lowerBound.utf16Offset(in: s)}

    return zip([0] + cutsStart, cutsEnd + [s.count]).map { start, end -> String in
        String(s[s.index(s.startIndex, offsetBy: start)..<s.index(s.startIndex, offsetBy: end)])
    }
}

func parseQRCode(_ code: String) -> WifiInfo {
    let parts = split(String(code.suffix(from: code.index(code.startIndex, offsetBy: kQuickConnectProto.count))), by: spliter)
    
    var info = WifiInfo()
    
    for p in parts.filter({ $0 != "" }) {
        let type = p.prefix(2)
        let value = String(p.suffix(from: p.index(p.startIndex, offsetBy: 2)))
        switch String(type) {
        case "S:":
            info.S = value
        case "P:":
            info.P = value
        case "C:":
            info.C = value
        case "M:":
            info.M = value
        default:()
            
        }
    }

    return info
}
