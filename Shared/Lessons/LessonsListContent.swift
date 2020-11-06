//
//  LessonsListContent.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct LessonsListContent: View {
    
    let nc = NotificationCenter.default
    
    enum Sort: String, CaseIterable, Identifiable {
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
    
    //MARK: - Environment
    
    @Environment(\.managedObjectContext) private var viewContext
    
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.editMode) var editMode
    #endif
    
    @AppStorage("currentLessonSort") private var sort: Sort = .dateDescending
    
    // MARK: - Selections
    @Binding var selection: Set<Lesson>
    
    @State var selectedLessons: [Lesson]? // for delete actions
    @State var selectedLesson: Lesson? // for editing lesson
    
    @EnvironmentObject var viewStates: LessonsStateObject
    @Binding var filter: LessonsFilter
    
    // MARK: - Model
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
    
    // MARK: - List
    var lessonList: some View {
        List(selection: $selection) {
            ForEach(filteredLessons, id: \.self) { lesson in
                LessonsRow(lesson: lesson)
                    .tag(lesson)
                    .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                        Button(action: {
                            let lesson = lesson as Lesson
                            viewStates.lessonToChange = lesson
                            viewStates.addLessonIsPresented = true
                        }, label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        })
                        Button(action: {toggleWatched(lessons: [lesson])}, label: {
                            !lesson.watched ? Label("Mark Watched", systemImage: "checkmark.circle")
                                : Label("Mark Unwatched", systemImage: "checkmark.circle")
                        })
                        Button(action: {
                            #if os(iOS)
                            selection = [lesson]
                            viewStates.shareSheetShown = true
                            #else
                            viewStates.shareSheetShown = true
                            #endif
                        }, label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        })
                        Button(action: {
                            selection = [lesson]
                            viewStates.deleteAlertShown = true
                        }, label: {
                            Label("Delete", systemImage: "trash")
                        })
                        .foregroundColor(.red)
                    }/*@END_MENU_TOKEN@*/)
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    // MARK: - Body
    var body: some View {
        Group {
            if filteredLessons.count > 0 {
                #if os(macOS)
                ScrollViewReader { proxy in
                    lessonList
                        .onDeleteCommand(perform: {viewStates.deleteAlertShown = true})
                        .navigationTitle(titleString)
                        .navigationSubtitle("\(filteredLessons.count) Lessons")
                        .listStyle(InsetListStyle())
                        .onReceive(nc.publisher(for: .scrollToNow), perform: { _ in
                            scrollToNow(proxy: proxy)
                        })
                }
                #else
                ScrollViewReader { proxy in
                    lessonList
                        .navigationTitle(titleString)
                        .onReceive(nc.publisher(for: .scrollToNow), perform: { _ in
                            scrollToNow(proxy: proxy)
                        })
                        .overlay(LessonsActionButtons(selection: $selection), alignment: .trailing)
                        .overlay(LessonsPrimaryActionButton(), alignment: .leading)
                }
                .alert(isPresented: $viewStates.deleteAlertShown) {
                    Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action cannt be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {viewStates.deleteAlertShown = false; viewStates.lessonToChange = nil}))
                }
                .popover(isPresented: $viewStates.shareSheetShown) {
                    ShareSheet(isPresented: $viewStates.shareSheetShown, activityItems: [Lesson.export(lessons: Array(selection))!])
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
        .sheet(isPresented: $viewStates.addLessonIsPresented,
               onDismiss: {
                viewStates.lessonToChange = nil
               }, content: {
                AddLessonView(lesson: viewStates.lessonToChange, isPresented: $viewStates.addLessonIsPresented, type: filter.lessonType ?? .lecture).environment(\.managedObjectContext, viewContext)
               })
        .toolbar {
            #if !os(macOS)
            /* BOTTOM BAR BREAKS IN STACKNAVIGATIONVIEWSTYLE
            ToolbarItemGroup(placement: .bottomBar) {
                BottomToolbar(selection: $selection, lessonCount: filteredLessons.count)
            }*/
            ToolbarItem(placement: .primaryAction) {
                Button(action: addLesson, label: {
                    Label("Add Lesson", systemImage: "plus")
                })
                .onReceive(nc.publisher(for: .newLesson), perform: { _ in
                    addLesson()
                })
                .help("Add a New Lesson")
            }
            #endif
        }
        .onReceive(nc.publisher(for: .deleteLessons), perform: { _ in
            viewStates.deleteAlertShown = true
        })
        .onReceive(nc.publisher(for: .exportLessons), perform: { _ in
            #if os(iOS)
            viewStates.shareSheetShown = true
            #endif
        })
    }
    
    func addLesson() {
        viewStates.addLessonIsPresented = true
    }
    
    private func deleteItems(offsets: IndexSet) {
        offsets.map { filteredLessons[$0] }.forEach { lesson in
            selection = [lesson]
            viewStates.deleteAlertShown = true
        }
    }
    
    private func deleteLessons() {
        withAnimation {
            viewStates.lessonToChange?.delete(context: viewContext)
            for lesson in selection {
                lesson.delete(context: viewContext)
            }
        }
        viewStates.lessonToChange = nil
        selection.removeAll()
    }
    
    private func toggleWatched(lessons: [Lesson]) {
        #if os(iOS)
        for lesson in lessons {
            lesson.toggleWatched(context: viewContext)
        }
        #else
        for lesson in selection {
            lesson.toggleWatched(context: viewContext)
        }
        #endif
    }
    
    private func scrollToNow(proxy: ScrollViewProxy) {
        guard filteredLessons.count > 0 else { return }
        let sortedLessons = filteredLessons.sorted(by: {$0.date! < $1.date!})
        
        if let nextLesson = sortedLessons.first(where: {$0.date ?? Date(timeIntervalSince1970: 0) > Date()}) {
            withAnimation {
                proxy.scrollTo(nextLesson)
            }
        } else {
            withAnimation {
                proxy.scrollTo(sortedLessons.last!)
            }
        }
    }
    
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(filter: LessonsFilter(filterType: .all, lessonType: nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
