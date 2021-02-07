//
//  SafariView.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 07/02/2021.
//

import SwiftUI
import SafariServices

struct SafariView: UIViewControllerRepresentable {
    
    var url: URL
    
    func makeUIViewController(context: Context) -> some UIViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        return
    }
}
