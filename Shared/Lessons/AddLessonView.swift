//
//  AddLessonView.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct AddLessonView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    /*@FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>*/
    
    @Binding var lesson: Lesson?
    @Binding var isPresented: Bool
    @State var type: Lesson.LessonType = .lecture
    @State var tags = [Tag]()
    
    @State var title: String = ""
    @State var location: String = ""
    @State var teacher: String = ""
    @State var date: Date = Date()
    @State var isCompleted: Bool = false
    var body: some View {
        #if os(macOS)
        AddLessonForm(lesson: $lesson, tags: $tags, isPresented: $isPresented, type: $type, title: $title, location: $location, teacher: $teacher, date: $date, isCompleted: $isCompleted)
            .padding()
        #else
        NavigationView {
            AddLessonForm(lesson: $lesson, tags: $tags, isPresented: $isPresented, type: $type, title: $title, location: $location, teacher: $teacher, date: $date, isCompleted: $isCompleted)
            .navigationTitle("Add Class")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: createLesson, label: {
                        Text("Save")
                    })
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {isPresented = false}, label: {
                        Text("Cancel")
                    })
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    func createLesson() {
        if lesson == nil {
            Lesson.create(in: managedObjectContext, title: title, type: type, teacher: teacher, date: date, location: location, watched: isCompleted, save: true, tags: tags)
        } else {
            lesson!.update(in: managedObjectContext, title: title, type: type, teacher: teacher, date: date, location: location, watched: isCompleted, tags: tags)
        }
        isPresented = false
    }
}

struct AddLessonForm: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @State private var hasUpdatedFields = false
    @Binding var lesson: Lesson?
    @Binding var tags: [Tag]
    @Binding var isPresented: Bool
    @Binding var type: Lesson.LessonType
    @Binding var title: String
    @Binding var location: String
    @Binding var teacher: String
    @Binding var date: Date
    @Binding var isCompleted: Bool
    var body: some View {
        Form {
            HStack {
                Image(systemName: "textformat")
                TextField("Title", text: $title)
            }
            HStack {
                Image(systemName: "mappin")
                TextField("Location", text: $location)
            }
            HStack {
                Image(systemName: "graduationcap")
                #if os(macOS)
                TextField("Teacher", text: $teacher)
                #else
                TextField("Teacher", text: $teacher)
                    .textContentType(.name)
                #endif
            }
            DatePicker(selection: $date) {
                Label("Date", systemImage: "calendar")
            }
            Picker(selection: $type, label: Label("Lesson Type", systemImage: "book"), content: /*@START_MENU_TOKEN@*/{
                ForEach(Lesson.LessonType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }/*@END_MENU_TOKEN@*/)
            .pickerStyle(DefaultPickerStyle())
            Toggle(isOn: $isCompleted, label: {
                Text("Watched")
            })
            #if os(macOS)
            HStack {
                Spacer()
                Button(action: {isPresented = false}, label: {
                    Text("Cancel")
                })
                .keyboardShortcut(.cancelAction)
                Button(action: createLesson, label: {
                    Text("Save")
                })
                .keyboardShortcut(.defaultAction)
            }
            #else
            NavigationLink(destination: AllocateTagView(selectedTags: $tags),
                label: {
                    Label("Choose Tags", systemImage: "tag")
                })
                .navigationTitle("Choose Tags")
            #endif
        }
        .onAppear(perform: {
            guard !hasUpdatedFields else { return }
            if let lesson = self.lesson {
                hasUpdatedFields = true
                date = lesson.date ?? Date()
                title = lesson.title ?? ""
                isCompleted = lesson.watched
                location = lesson.location ?? ""
                teacher = lesson.teacher ?? ""
                type = Lesson.LessonType(rawValue: lesson.type ?? "") ?? .lecture
                tags = lesson.tag?.allObjects as! [Tag]
            }
        })
    }
    func createLesson() {
        if lesson == nil {
            Lesson.create(in: managedObjectContext, title: title, type: type, teacher: teacher, date: date, location: location, watched: isCompleted, save: true, tags: tags)
        } else {
            lesson!.update(in: managedObjectContext, title: title, type: type, teacher: teacher, date: date, location: location, watched: isCompleted, tags: tags)
        }
        isPresented = false
    }
}

struct AddLessonView_Previews: PreviewProvider {
    static var previews: some View {
        AddLessonView(lesson: .constant(nil), isPresented: .constant(true), type: Lesson.LessonType.lecture, title: "", location: "", teacher: "", date: Date(), isCompleted: false)
    }
}