//
//  OnboardingContent.swift
//  Classes
//
//  Created by Nick Baughan on 05/02/2021.
//

import SwiftUI

struct OnboardingContent: View {
    let content: [OnboardingView.OnboardingModel]
    @Binding var currentScreen: Int
    
    @ViewBuilder
    func image(_ model: OnboardingView.OnboardingModel) -> some View {
        if content[currentScreen].sfSymbol {
            Image(systemName: content[currentScreen].image)
                .resizable()
        } else {
                Image(content[currentScreen].image)
                .resizable()
                .cornerRadius(8)
        }
    }
    
    var body: some View {
        GeometryReader { gr in
            VStack(alignment: .center) {
                
                ForEach(content.indices, id: \.self) { index in
                    if currentScreen == index {
                        HStack {
                            Spacer()
                            image(content[index])
                                .aspectRatio(contentMode: .fill)
                                .frame(width: gr.size.height / 4, height: gr.size.height / 4)
                                .foregroundColor(.accentColor)
                                .shadow(radius: 10)
                                .padding()
                            Spacer()
                        }
                    }
                }
                    #if os(macOS)
                    VStack(alignment: .leading) {
                        ForEach(content.indices, id: \.self) { index in
                            if index == currentScreen {
                                VStack(alignment: .leading) {
                                    Text(content[index].title)
                                        .font(.title2)
                                        .bold()
                                    ScrollView {
                                        content[index].text
                                    }
                                }
                            }
                        }
                    }
                    #else
                    TabView(selection: $currentScreen) {
                        ForEach(content.indices, id: \.self) { index in
                            VStack(alignment: .leading) {
                                Text(content[index].title)
                                    .font(.title2)
                                    .bold()
                                ScrollView {
                                    content[index].text
                                }
                            }
                            .tag(index)
                        }
                    }.tabViewStyle(PageTabViewStyle())
                    #endif
            }
            .foregroundColor(.white)
        }
    }
}

struct OnboardingContent_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingContent(content: [.init(id: 0, title: "Title", image: "heart.fill", sfSymbol: true, text: Text("Text text text"))], currentScreen: .constant(0))
    }
}
