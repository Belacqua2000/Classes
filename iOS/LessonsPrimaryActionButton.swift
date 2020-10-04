//
//  LessonsPrimaryActionButton.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 04/10/2020.
//

import SwiftUI

struct LessonsPrimaryActionButton: View {
    let nc = NotificationCenter.default
    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            HStack(alignment: .bottom) {
                ZStack {
                    ActionButtonsBackground(numberOfButtons: 1)
                        .frame(width: 60)
                    Button(action: {
                        nc.post(Notification(name: .scrollToNow))
                    }, label: {
                        ActionButtonItem(imageName: "calendar.badge.clock")
                    })
                        .frame(width: 50)
                }
                Spacer()
            }
            .padding()
        }
    }
}

struct LessonsPrimaryActionButton_Previews: PreviewProvider {
    static var previews: some View {
        LessonsPrimaryActionButton()
    }
}
