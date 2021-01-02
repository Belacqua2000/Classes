//
//  LessonsActionButtons.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 04/10/2020.
//

import SwiftUI

struct LessonsActionButtons: View {
    @Environment(\.editMode) var editMode
    @Environment(\.managedObjectContext) var viewContext
    
    @Binding var selection: Set<Lesson>
    
    let nc = NotificationCenter.default
    var numberOfButtons: Double {
        return editMode?.wrappedValue.isEditing == true ? 3.5 : 1
    }
    var body: some View {
        VStack(alignment: .trailing) {
            Spacer()
            HStack(alignment: .bottom) {
                Spacer()
                ZStack {
                    ActionButtonsBackground(numberOfButtons: numberOfButtons)
                        .frame(width: 50)
                    VStack {
                        if editMode?.wrappedValue.isEditing == true {
                            Button(action: {
                                nc.post(Notification(name: .exportLessons))
                            }, label: {
                                ActionButtonItem(imageName: "square.and.arrow.up")
                            })
                            .onAppear(perform: {
                                selection.removeAll()
                            })
                            .onDisappear(perform: {
                                selection.removeAll()
                            })
                            
                            Button(action: {
                                nc.post(Notification(name: .deleteLessons))
                            }, label: {
                                ActionButtonItem(imageName: "trash")
                            })
                            
                            Button(action: {
                                withAnimation {
                                    for lesson in selection {
                                        lesson.toggleWatched(context: viewContext)
                                    }
                                }
                            }, label: {
                                ActionButtonItem(imageName: "checkmark.circle")
                            })
                        }
                        EditButton()
                            .font(.caption)
                            .foregroundColor(Color(.label))
                            .animation(.default)
                    }
                    .frame(width: 35)
                }
            }
            .padding()
        }
    }
}

struct LessonsActionButtons_Previews: PreviewProvider {
    static var previews: some View {
        LessonsActionButtons(selection: .constant(Set<Lesson>()))
            .frame(width: 50)
    }
}

struct ActionButtonsBackground: View {
    var numberOfButtons: Double
    var body: some View {
        Capsule()
            .aspectRatio(CGSize(width: 1, height: numberOfButtons), contentMode: .fit)
            .foregroundColor(Color("SecondaryColorTranslucent"))
            .shadow(radius: 10)
    }
}

struct ActionButtonItem: View {
    var imageName: String
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(Color(.label))
            .padding(5)
    }
}


/*
 //
 //  LessonsActionButtons.swift
 //  Classes (iOS)
 //
 //  Created by Nick Baughan on 04/10/2020.
 //
 
 import SwiftUI
 
 struct LessonsActionButtons<Content:View>: View {
 @Environment(\.editMode) var editMode
 
 var editingToolbar: Bool
 let content: (ActionButtonItem) -> Content
 
 var numberOfButtons: Int {
 if editingToolbar {
 return editMode?.wrappedValue.isEditing == true ? buttons.count + 1 : 1
 } else {
 return buttons.count
 }
 }
 
 var body: some View {
 ZStack {
 ActionButtonsBackground(numberOfButtons: numberOfButtons)
 VStack {
 if !editingToolbar || editMode?.wrappedValue.isEditing == true {
 ForEach(0..<numberOfButtons) { button in
 content[button]
 }
 }
 if editingToolbar {
 EditButton()
 .foregroundColor(.black)
 .font(.title)
 }
 }
 }
 }
 }
 
 struct LessonsActionButtons_Previews: PreviewProvider {
 static var previews: some View {
 LessonsActionButtons(editingToolbar: true) { button in
 ActionButtonItem()
 }
 }
 }
 
 struct ActionButtonsBackground: View {
 var numberOfButtons: Int
 var body: some View {
 Capsule()
 .aspectRatio(CGSize(width: 1, height: numberOfButtons), contentMode: .fit)
 .foregroundColor(Color("SecondaryColor"))
 }
 }
 
 struct ActionButtonItem: View, Identifiable {
 let id = UUID()
 var body: some View {
 Image(systemName: "clock")
 .resizable()
 .aspectRatio(contentMode: .fit)
 .padding(60)
 .foregroundColor(.black)
 }
 }
 */
