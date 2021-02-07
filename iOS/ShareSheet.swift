//
//  ShareSheet.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 07/02/2021.
//

import SwiftUI

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
