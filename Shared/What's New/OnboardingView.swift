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
        .init(id: 0, title: "What can you do with Classes?", image: "AppIcon Inside", sfSymbol: false, text: Text("At university/college, it can be hard to keep track of when your classes are, and what you are supposed to be learning.  When studying for exams, remembering all of the topics you need to cover can be daunting, and can lead to inefficient studying.\n\nClasses is designed to help you easily create a personalised ‘all-you-need database’ for your university classes, whether they be lectures, tutorials, or self-study assignments!")),
        .init(id: 1, title: "Getting Started", image: "Onboarding Add Lesson", sfSymbol: false, text: Text("First, add your lessons by pressing \(Image(systemName: "plus")) in the toolbar.  You can fill their location, date, and teacher to help you find it later.  If you have been given lesson outcomes, add these by pressing \(Image(systemName: "text.badge.plus")).  Add brief notes and URL resources you would like to keep with the lesson.")),
        .init(id: 2, title: "Tracking Progress", image: "book.fill", text: Text("When you have watched/completed a lesson, press “watched”.  Check off the learning outcomes as you write them.")),
        .init(id: 3, title: "More Tips", image: "book.fill", text: Text("That’s it!  Quick tips:\n- Use the sidebar to quickly find lessons you have yet to watch and write up.\n- Use the tags feature to organise lessons by topic and/or type.\n- Use the outcome randomiser to give you random topics to study based on criteria you set."))
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
