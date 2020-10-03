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

struct ShareSheet: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        
        let viewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        
        viewController.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
            self.isPresented = false }
        
        return viewController
    }
    
    func updateUIViewController(_ activityViewController: UIActivityViewController, context: Context) {
        
    }
}
