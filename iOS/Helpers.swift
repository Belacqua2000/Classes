//
//  Helpers.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 21/09/2020.
//

import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
