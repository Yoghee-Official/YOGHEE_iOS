//
//  Extension+View.swift
//  YOGHEE
//
//  Created by 0ofKim on 11/4/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
}
