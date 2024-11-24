//
//  Utilities.swift
//  ExpensinatorMac
//
//  Created by Oliver Holmes on 11/20/24.
//

import Foundation
import SwiftUI

struct getScreenSize {
    static func width() -> CGFloat {
        return 1206
    }
    
    static func height() -> CGFloat {
        return 2622
    }
}


struct CustomColor {
    static let EerieBlack = Color(hex: "212529")
    static let green1 = Color(hex: "40bc7c")
    static let green2 = Color(hex: "6B994F")
    static let green3 = Color(hex: "A7C957")
    static let BittersweetShimmer = Color(hex: "BC4749")
    static let SnowWhite = Color(hex: "FFFBFA")
    static let lightThemeColor = Color(hex: "6A994E")
    static let orange = Color(hex: "FF6B00")
    static let red = Color(hex: "#FF2F2F")
    static let successGreen = Color(hex: "027A48")
}

// MARK: - Converting Hexadecimal to RGB
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


