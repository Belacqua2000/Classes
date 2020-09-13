//
//  LessonsListContent.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct LessonsListContent: View {
    
    private enum Sort: String, CaseIterable, Identifiable {
        var id: String { return rawValue }
        case dateAscending = "Oldest"
        case dateDescending = "Newest"
        case name = "Name"
    }
    
  
    @AppStorage("currentLessonSort") private var sort: Sort = .dateDescending
    
    @State var selection = Set<Lesson>()
    @State var selectedLesson: Lesson? = nil
    @State var sheetIsPresented: Bool = false
    
    @Binding var filter: LessonsView.Filter
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
        animation: .default)
    private var lessons: FetchedResults<Lesson>
    
    private var filteredLessons: [Lesson] {
        var filterHelper = [Lesson]()
        switch filter.filterType {
        case .all:
            filterHelper = lessons.filter({ !$0.isDeleted })
        case .tag:
            guard let passedTag = filter.tag else { filterHelper = lessons.filter({ !$0.isDeleted });break }
            filterHelper = lessons.filter({ ($0.tag?.contains(passedTag) ?? !$0.isDeleted)})
        case .lessonType:
            switch filter.lessonType {
            case .lecture:
                filterHelper = lessons.filter({ $0.type == Lesson.LessonType.lecture.rawValue })
            case .tutorial:
                filterHelper = lessons.filter({ $0.type == Lesson.LessonType.tutorial.rawValue })
            case .pbl:
                filterHelper = lessons.filter({ $0.type == Lesson.LessonType.pbl.rawValue })
            case .cbl:
                filterHelper = lessons.filter({ $0.type == Lesson.LessonType.cbl.rawValue })
            case .lab:
                filterHelper = lessons.filter({ $0.type == Lesson.LessonType.lab.rawValue })
            case .none:
                filterHelper = lessons.filter({ !$0.isDeleted })
            }
        case .watched:
            return filterHelper.filter({ $0.watched })
        }
        
        switch sort {
        case .dateAscending:
            filterHelper.sort(by: {$0.date! < $1.date!})
        case .dateDescending:
            filterHelper.sort(by: {$0.date! > $1.date!})
        case .name:
            filterHelper.sort(by: {$0.title! < $1.title!})
        }
        
        return filterHelper
    }
    
    var lessonList: some View {
            List(selection: $selection) {
                ForEach(filteredLessons, id: \.self) { lesson in
                    NavigationLink(
                        destination:
                            DetailView(lesson: lesson)
                        ,
                        label: {
                            LessonCell(lesson: lesson)
                        })
                        .onDrag({
                            let itemProvider = NSItemProvider(object: lesson.id!.uuidString as NSString)
                            return(itemProvider)
                        })
                        .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                            Button(action: {
                                selectedLesson = lesson
                                sheetIsPresented = true
                            }, label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            })
                            Button(action: {lesson.toggleWatched(context: viewContext)}, label: {
                                !lesson.watched ? Label("Mark Watched", systemImage: "checkmark.circle")
                                : Label("Mark Unwatched", systemImage: "checkmark.circle")
                            })
                            Button(action: {lesson.delete(context: viewContext)}, label: {
                                Label("Delete", systemImage: "trash")
                            })
                        }/*@END_MENU_TOKEN@*/)
                    //#endif
                }
                .onDelete(perform: deleteItems)
            }
            .listStyle(InsetListStyle())
    }
    
    var body: some View {
        VStack {
            if filteredLessons.count != 0 {
                #if os(macOS)
                lessonList
                    .navigationSubtitle("\(filteredLessons.count) Lessons")
                #else
                Picker("Sort", selection: $sort, content: {
                    ForEach(Sort.allCases) { sort in
                        Text(sort.rawValue).tag(sort)
                    }
                })
                .padding(.horizontal)
                .pickerStyle(SegmentedPickerStyle())
                lessonList
                #endif
            } else {
                Text("No Classes.  Click the + button in the toolbar to create one.")
                    .padding()
            }
        }
        .sheet(isPresented: $sheetIsPresented, onDismiss: {
            selectedLesson = nil
        }, content: {
            if let lesson = selectedLesson {
                let tags = lesson.tag?.allObjects as? [Tag]
                AddLessonView(lesson: lesson, isPresented: $sheetIsPresented, type: Lesson.LessonType(rawValue: lesson.type!)!, tags: tags ?? [], title: lesson.title!, location: lesson.location!, teacher: lesson.teacher!, date: lesson.date!, isCompleted: lesson.watched)
                    .frame(minWidth: 200, idealWidth: 400, minHeight: 200, idealHeight: 250)
            } else {
                AddLessonView(isPresented: $sheetIsPresented, type: .lecture)
                    .frame(minWidth: 200, idealWidth: 400, minHeight: 200, idealHeight: 250)
            }
        })
        .toolbar {
            #if os(iOS)
            //EditButton()
            #endif
            ToolbarItemGroup(placement: .automatic) {
                #if os(macOS)
                Menu(content: {
                        Section(header: Text("Sort")) {
                    Button(action: {
                        sort = .dateAscending
                    }, label: {
                        Label("Oldest", systemImage: "calendar")
                    })
                    .disabled(sort == .dateAscending)
                    .help("Sort the list of lessons in an ascending date order.")
                    Button(action: {
                        sort = .dateDescending
                    }, label: {
                        Label("Newest", systemImage: "calendar")
                    })
                    .disabled(sort == .dateDescending)
                    .help("Sort the list of lessons in a descending date order.")
                    Button(action: {
                        sort = .name
                    }, label: {
                        Label("Name", systemImage: "calendar")
                    })
                    .disabled(sort == .name)
                    .help("Sort the list of lessons by name.")
                        }
                }, label: {
                    Label("Sort and Filter", systemImage: "line.horizontal.3.decrease.circle")
                })
                .help("Sort and Filter the List")
                #endif
                Button(action: addLesson, label: {
                    Label("Add Lesson", systemImage: "plus")
                })
                .help("Add a New Lesson")
            }
    }
    }
    
    func addLesson() {
        sheetIsPresented = true
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredLessons[$0] }.forEach { lesson in
                lesson.delete(context: viewContext)
            }
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(filter: LessonsView.Filter(filterType: .all, lessonType: nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
