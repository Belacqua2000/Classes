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
    @State var notes: String = ""
    var body: some View {
        #if os(macOS)
        AddLessonForm(lesson: $lesson, tags: $tags, isPresented: $isPresented, type: $type, title: $title, location: $location, teacher: $teacher, date: $date, isCompleted: $isCompleted, notes: $notes)
            .padding()
            .frame(idealWidth: 400)
        #else
        NavigationView {
            AddLessonForm(lesson: $lesson, tags: $tags, isPresented: $isPresented, type: $type, title: $title, location: $location, teacher: $teacher, date: $date, isCompleted: $isCompleted, notes: $notes)
                .navigationTitle(lesson == nil ? "Add Lesson" : "Edit Lesson")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: createLesson, label: {
                        Text("Save")
                    })
                    .disabled(title == "")
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
            Lesson.create(in: managedObjectContext, title: title, type: type, teacher: teacher, date: date, location: location, watched: isCompleted, save: true, tags: tags, notes: notes)
        } else {
            lesson!.update(in: managedObjectContext, title: title, type: type, teacher: teacher, date: date, location: location, watched: isCompleted, tags: tags, notes: notes)
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
    @Binding var notes: String
    
    var editorHeight: CGFloat {
        #if os(macOS)
        return 100
        #else
        return 200
        #endif
    }
    
    var body: some View {
        Form {
            Section {
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
            }
            Section(header: Text("Notes")) {
                #if os(macOS)
                TextEditor(text: $notes)
                    .border(Color(.labelColor), width: 1)
                    .frame(height: editorHeight)
                #else
                TextEditor(text: $notes)
                    .frame(height: editorHeight)
                #endif
            }
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
                .disabled(title == "")
                .keyboardShortcut(.defaultAction)
            }
            #else
            Section {
                NavigationLink(destination: AllocateTagView(selectedTags: $tags).environment(\.managedObjectContext, managedObjectContext),
                               label: {
                                Label("Choose Tags", systemImage: "tag")
                               })
            }
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
                notes = lesson.notes ?? ""
            }
        })
    }
    func createLesson() {
        if lesson == nil {
            Lesson.create(in: managedObjectContext, title: title, type: type, teacher: teacher, date: date, location: location, watched: isCompleted, save: true, tags: tags, notes: notes)
        } else {
            lesson!.update(in: managedObjectContext, title: title, type: type, teacher: teacher, date: date, location: location, watched: isCompleted, tags: tags, notes: notes)
        }
        isPresented = false
    }
}

struct AddLessonView_Previews: PreviewProvider {
    static var previews: some View {
        AddLessonView(lesson: .constant(nil), isPresented: .constant(true), type: Lesson.LessonType.lecture, title: "", location: "", teacher: "", date: Date(), isCompleted: false)
    }
}
