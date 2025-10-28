//
//  Font+Remy.swift
//  Remy
//
//  Created by Keshav krishnan on 10/17/25.
//

import SwiftUI

extension Font {
    static let remyTitle = Font.system(size: 28, weight: .bold)
    static let remyHeadline = Font.system(size: 20, weight: .semibold)
    static let remyBody = Font.system(size: 16, weight: .regular)
    static let remyCaption = Font.system(size: 14, weight: .light)
}

extension CGFloat {
    // Spacing
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48

    // Corner Radius
    static let buttonRadius: CGFloat = 12
    static let cardRadius: CGFloat = 16
    static let modalRadius: CGFloat = 20
}

extension View {
    func remyCardShadow() -> some View {
        self.shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
