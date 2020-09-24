//
//  LessonsListContent.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct LessonsListContent: View {
    
    // This sets the navigationSubtitle of the PARENT NavigationView
    @Binding var lessonCount: Int
    
    private enum Sort: String, CaseIterable, Identifiable {
        var id: String { return rawValue }
        case dateAscending = "Oldest"
        case dateDescending = "Newest"
        case name = "Name"
    }
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.editMode) var editMode
    #endif
    
    @AppStorage("currentLessonSort") private var sort: Sort = .dateDescending
    
    @State var selection = Set<Lesson>() // for list selection
    @State var selectedLessons: [Lesson]? // for delete actions
    @State var selectedLesson: Lesson? // for editing lesson
    
    @State var sheetIsPresented: Bool = false
    @State private var deleteAlertShown = false
    @State private var detailShowing = false
    @State private var shareSheetPresented = false
    
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
        List {
            Picker("Sort", selection: $sort.animation(.default), content: {
                ForEach(Sort.allCases) { sort in
                    Text(sort.rawValue).tag(sort)
                }
            })
            .padding(.horizontal)
            .pickerStyle(SegmentedPickerStyle())
            ForEach(filteredLessons, id: \.self) { lesson in
                NavigationLink(
                    destination:
                        DetailView(lesson: lesson),
                    label: {
                        LessonCell(lesson: lesson)
                    })
                    .onDrag({
                        let itemProvider = NSItemProvider(object: lesson.id!.uuidString as NSString)
                        return(itemProvider)
                    })
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
                        Button("Export File") {
                            selectedLesson = lesson
                            shareSheetPresented = true
                        }
                        Button(action: {deleteLessonAlert(lessons: [lesson])}, label: {
                            Label("Delete", systemImage: "trash")
                        })
                        .foregroundColor(.red)
                    }/*@END_MENU_TOKEN@*/)
                //#endif
            }
            .onDelete(perform: deleteItems)
            .alert(isPresented: $deleteAlertShown) {
                Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action cannot be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLesson), secondaryButton: .cancel(Text("Cancel"), action: {deleteAlertShown = false; selectedLessons = nil}))
            }
        }
        .onAppear(perform: {lessonCount = filteredLessons.count})
    }
    
    var body: some View {
        VStack {
            if filteredLessons.count != 0 {
                #if os(macOS)
                lessonList
                    .listStyle(InsetListStyle())
                #else
                ScrollViewReader { proxy in
                    /*if filteredLessons.count > 0 {
                        Button("Scroll to Now", action: {proxy.scrollTo(scrollToNow())})
                    }*/
                    lessonList
                }
                #endif
            } else {
                Text("No Lessons.  Click the + button in the toolbar to create one.")
                    .padding()
            }
        }
        .popover(isPresented: $shareSheetPresented) {
            ShareSheet(isPresented: $shareSheetPresented, activityItems: [selectedLesson?.export()])
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
    
    private func scrollToNow() -> UUID {
        let sortedLessons = filteredLessons.sorted(by: {$0.date! < $1.date!})
        
        let nextLesson = sortedLessons.first(where: {$0.date ?? Date(timeIntervalSince1970: 0) > Date()})!
        
        print(nextLesson.id!)
        return nextLesson.id!
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
