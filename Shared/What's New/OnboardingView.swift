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
    @Environment(\.presentationMode) var presentationMode
    
    @State private var currentScreen: Int = 0
    
    private var maxIndex: Int {
        content.count - 1
    }
    
    private var nextButtonLabel: String {
        currentScreen != maxIndex ? "Next" : "Get Started"
    }
    
    private var drag: some Gesture {
        DragGesture()
            .onEnded { value in
                if value.location.x > value.startLocation.x {
                    nextItem()
                } else {
                    previousItem()
                }
            }
    }
    
    private var buttons: some View {
        HStack {
            Button("Previous", action: previousItem)
                .disabled(currentScreen == 0)
            Button(nextButtonLabel, action: nextItem)
        }
    }
    
    // MARK: - Model
    struct OnboardingModel: Identifiable {
        let id: Int
        let title: String
        let image: String
        var sfSymbol: Bool = true
        let text: Text
    }
    
    private let content: [OnboardingModel] = [
        .init(id: 0, title: "What can you do with Classes?", image: "AppIcon Inside", sfSymbol: false, text: Text("Keeping track of classes at university is difficult.\n\nRemembering all the topics you need to revise can be daunting.\n\nWith \(Text("Classes").italic()) you can easily create a personalised ‘all-you-need database’ for your university lessons, to keep organised and document all topics to revise.")),
        .init(id: 1, title: "Getting Started", image: "Onboarding Add Lesson", sfSymbol: false, text: Text("• Press \(Image(systemName: "plus")) in the toolbar to add your lessons.\n\n• Add their location, date, and teacher to help you find it later.\n\n• Add your lesson outcomes by pressing \(Image(systemName: "text.badge.plus")).\n\n• Add links to lecture slides or other resources you would like to keep with the lesson.")),
        .init(id: 2, title: "Tracking Progress", image: "Onboarding Tracking Progress", sfSymbol: false, text: Text("• Press '\(Image(systemName: "checkmark.circle")) Complete' when you have finished your lesson.\n\n• Check off the learning outcomes as you achieve them.\n\n• The lesson will have an indicator in the list to show it is completed, and a visual icon showing the number of outcomes achieved")),
        .init(id: 3, title: "Tips and Tricks", image: "Onboarding Overview", sfSymbol: false, text: Text("Time to get started!  Quick tips:\n\n• Lessons automatically sync between Mac, iPad, and iPhone using iCloud.\n\n• Use the tags feature to organise lessons by topic and/or type.\n\n• Use the outcome randomiser to give you random topics to study based on criteria you set.\n\nSee the Help section within Settings for more tips and tutorials."))
    ]
    
    // MARK: - Body
    var body: some View {
        ZStack {
            DetailBackgroundGradient().ignoresSafeArea()
            VStack(alignment: .center) {
                
                Spacer()
                
                Text("Welcome to Classes")
                    .font(.largeTitle)
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .foregroundColor(.white)
                
                Spacer()
                
                OnboardingContent(content: content, currentScreen: $currentScreen)
                
                Spacer()
                
                #if os(iOS)
                buttons
                    .buttonStyle(LargeButton())
                #else
                buttons
                #endif
                
            }
            .padding()
        }
    }
    
    private func nextItem() {
        if currentScreen < maxIndex {
            withAnimation {
                currentScreen += 1
            }
        } else {
            dismissView()
        }
    }
    
    private func previousItem() {
        guard currentScreen > 0 else { return }
        withAnimation {
            currentScreen -= 1
        }
    }
    
    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .frame(minWidth: 200, maxWidth: .infinity, minHeight: 400, maxHeight: .infinity)
    }
}

struct LargeButton: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        #if os(iOS)
        return configuration.label
            .padding()
            .frame(minWidth: 120)
            .foregroundColor(.white)
            .background(configuration.isPressed ? Color.gray : Color.accentColor)
            .cornerRadius(8)
        #else
        return configuration.label
            .frame(minWidth: 120)
        #endif
    }
}
