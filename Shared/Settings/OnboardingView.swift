//
//  OnboardingView.swift
//  Classes
//
//  Created by Nick Baughan on 19/09/2020.
//

import SwiftUI

struct OnboardingView: View {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    #endif
//    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        GeometryReader { gr in
            VStack(alignment: .center) {
                ScrollView {
                    Text("Welcome to Classes")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    Text("Classes helps you organise your study life.")
                        .font(.callout)
                    Image("AppIcon Inside")
                        .resizable()
                        .cornerRadius(16)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: gr.size.height * 0.3)
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Features")
                            .font(.title2)
                            .bold()
                        Text("• Add lessons by pressing the \(Image(systemName: "plus")) button in the toolbar.")
                        Text("• Assign multiple tags to organise your lessons.")
                        Text("• Add learning outcomes for each lesson, and use the outcome randomiser to give you topics to study.")
                        Text("• Use the summary view to manage your workload and prioritise your day.")
                        Text("• Sync all of your lessons over iCloud.")
                    }
                }
                #if os(macOS)
                Button("Get Started", action: {
                    presentationMode.wrappedValue.dismiss()
                }).keyboardShortcut(.defaultAction)
                #else
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Get Started")
                        .frame(width: 300, height: 50)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                })
                #endif
            }
            .padding()
        }
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
    }
}
