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
    
    var titleString: String {
        switch filter.filterType {
        case .all:
            return("All Lessons")
        case .tag:
            return("Tag: \(filter.tag?.name ?? "")")
        case .lessonType:
            return Lesson.lessonTypePlural(type: filter.lessonType?.rawValue)
        case .watched:
            return("Watched Lessons")
        }
    }
    
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.editMode) var editMode
    #endif
    
    @AppStorage("currentLessonSort") private var sort: Sort = .dateDescending
    
    #if os(iOS)
    @State var selection = Set<Lesson>() // for list selection
    #elseif os(macOS)
    @Binding var selection: Set<Lesson>
    #endif
    @State var selectedLessons: [Lesson]? // for delete actions
    @State var selectedLesson: Lesson? // for editing lesson
    
    @State private var myLesson: Lesson?
    
    @State var sheetIsPresented: Bool = false
    @State private var deleteAlertShown = false
    @State private var detailShowing = false
    
    @Binding var filter: LessonsFilter
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
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
            case .clinical:
                filterHelper = lessons.filter({ $0.type == Lesson.LessonType.clinical.rawValue })
            case .selfStudy:
                filterHelper = lessons.filter({ $0.type == Lesson.LessonType.selfStudy.rawValue })
            case .video:
                filterHelper = lessons.filter({ $0.type == Lesson.LessonType.video.rawValue })
            case .other:
                filterHelper = lessons.filter({ $0.type == Lesson.LessonType.other.rawValue })
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
            #if os(iOS)
            Picker("Sort", selection: $sort.animation(.default), content: {
                ForEach(Sort.allCases) { sort in
                    Text(sort.rawValue).tag(sort)
                }
            })
            .padding(.horizontal)
            .pickerStyle(SegmentedPickerStyle())
            #endif
            ForEach(filteredLessons, id: \.self) { lesson in
                LessonsRow(lesson: lesson)
                    .tag(lesson)
                .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                    Button(action: {
                        let lesson = lesson as Lesson
                        selectedLesson = lesson
                        sheetIsPresented = true
                    }, label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    })
                    Button(action: {toggleWatched(lessons: [lesson])}, label: {
                        !lesson.watched ? Label("Mark Watched", systemImage: "checkmark.circle")
                            : Label("Mark Unwatched", systemImage: "checkmark.circle")
                    })
                    Button(action: {deleteLessonAlert(lessons: [lesson])}, label: {
                        Label("Delete", systemImage: "trash")
                    })
                    .foregroundColor(.red)
                }/*@END_MENU_TOKEN@*/)
            }
            .onDelete(perform: deleteItems)
            .alert(isPresented: $deleteAlertShown) {
                Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action cannot be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLesson), secondaryButton: .cancel(Text("Cancel"), action: {deleteAlertShown = false; selectedLessons = nil}))
            }
        }
    }
    
    var body: some View {
        Group {
            if filteredLessons.count > 0 {
                #if os(macOS)
                lessonList
                    .navigationTitle(titleString)
                    .navigationSubtitle("\(filteredLessons.count) Lessons")
                    .listStyle(InsetListStyle())
                #else
                ScrollViewReader { proxy in
                    if filteredLessons.count > 0 {
                        Button("Scroll to Now", action: {proxy.scrollTo(scrollToNow())})
                    }
                    lessonList
                        .navigationTitle(titleString)
                }
                #endif
            } else {
                #if os(macOS)
                Text("No Lessons.  Click the + button in the toolbar to create one.")
                    .padding()
                    .navigationTitle(titleString)
                    .navigationSubtitle("\(filteredLessons.count) Lessons")
                #else
                Text("No Lessons.  Click the + button in the toolbar to create one.")
                    .navigationTitle(titleString)
                    .padding()
                #endif
            }
        }
        .sheet(isPresented: $sheetIsPresented, onDismiss: {
            selectedLessons = nil
        }, content: {
            AddLessonView(lesson: $selectedLesson, isPresented: $sheetIsPresented).environment(\.managedObjectContext, viewContext)
                .frame(minWidth: 200, idealWidth: 400, minHeight: 200, idealHeight: 250)
        })
        .toolbar {
            #if !os(macOS)
            /*ToolbarItem(placement: .navigationBarLeading) {
             EditButton()
             }
             
             ToolbarItemGroup(placement: .bottomBar) {
             if editMode?.wrappedValue.isEditing == true {
             Button(action: {deleteLessonAlert(lessons: Array(selection))}, label: {
             Label("Delete", systemImage: "trash")
             })
             Spacer()
             Button(action: {toggleWatched(lessons: Array(selection))}, label: {
             Label("Toggle Watched", systemImage: "checkmark.circle.fill")
             })
             }
             }*/
            #endif
            ToolbarItemGroup(placement: .primaryAction) {
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
                #if os(macOS)
                Spacer()
                #endif
            }
        }
    }
    
    func addLesson() {
        sheetIsPresented = true
    }
    
    private func deleteLessonAlert(lessons: [Lesson]) {
        selectedLessons = lessons
        deleteAlertShown = true
    }
    
    private func deleteLesson() {
        guard let lessons = selectedLessons else { return }
        withAnimation {
            for lesson in lessons {
                lesson.delete(context: viewContext)
            }
        }
        selectedLessons = nil
    }
    
    private func deleteItems(offsets: IndexSet) {
        offsets.map { filteredLessons[$0] }.forEach { lesson in
            deleteLessonAlert(lessons: [lesson])
        }
    }
    
    private func toggleWatched(lessons: [Lesson]) {
        for lesson in lessons {
            lesson.toggleWatched(context: viewContext)
        }
    }
    
    private func scrollToNow() -> Lesson? {
        let sortedLessons = filteredLessons.sorted(by: {$0.date! < $1.date!})
        
        guard let nextLesson = sortedLessons.first(where: {$0.date ?? Date(timeIntervalSince1970: 0) > Date()}) else { return nil }
        
        print(nextLesson.id!)
        return nextLesson.self
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
        LessonsView(filter: LessonsFilter(filterType: .all, lessonType: nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
