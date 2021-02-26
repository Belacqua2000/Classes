//
//  LessonsListContent.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct LessonsListContent: View {
    
    enum Sheets: String, Identifiable {
        var id: String { return rawValue }
        case addLesson
        case filter
        case ilo
        
    }
    
    @State var sheetToPresent: LessonsListContent.Sheets?
    
    let nc = NotificationCenter.default
    
    // Sort
    enum Sort: String, CaseIterable, Identifiable {
        var id: String { return rawValue }
        case dateAscending = "Oldest"
        case dateDescending = "Newest"
        case name = "Title"
        case location = "Location"
        case teacher = "Teacher"
    }
    
    var titleString: String {
        switch listType.filterType {
        case .all:
            return("All Lessons")
        case .tag:
            return listType.tag?.name ?? ""
        case .lessonType:
            return Lesson.lessonTypePlural(type: listType.lessonType?.rawValue)
        case .watched:
            return("Watched Lessons")
        case .today:
            return "Today's Lessons"
        case .unwatched:
            return "Uncompleted Lessons"
        case .unwritten:
            return "Unachieved Outcomes"
        }
    }
    
    //MARK: - Environment
    
    @Environment(\.managedObjectContext) private var viewContext
    
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.editMode) var editMode
    #endif
    
    @AppStorage("currentLessonSort") private var sort: Sort = .dateAscending
    
    // MARK: - Selections
    
    @StateObject var listHelper: LessonsListHelper
    
    @Binding var listType: LessonsListType
    @StateObject var listFilter = LessonsListFilter()
    @State var alertShowing = false // For some reason this must be local for alert to show on Mac
    @State var lessonToDelete: Lesson? // For some reason this must be local for alert to show on Mac
    
    // MARK: - Model
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
                  animation: .default)
    private var lessons: FetchedResults<Lesson>
    
    private var filteredLessons: [Lesson] {
        
        var filterHelper = [Lesson]()
        
        // Apply filters based on list type sent from parent view
        switch listType.filterType {
        case .all:
            filterHelper = lessons.filter({ !$0.isDeleted })
        case .tag:
            guard let passedTag = listType.tag else { filterHelper = lessons.filter({ !$0.isDeleted });break }
            filterHelper = lessons.filter({ ($0.tag?.contains(passedTag) ?? !$0.isDeleted)})
        case .lessonType:
            switch listType.lessonType {
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
            
        case .today:
            let calendar = Calendar.current
            filterHelper = lessons.filter({calendar.isDateInToday($0.date!)})
            
        case .unwatched:
            filterHelper = lessons.filter({!$0.watched})
            
        case .unwritten:
            filterHelper = lessons.filter({ ($0.ilo?.allObjects as! [ILO]).contains(where: { ilo in !ilo.written})})
        case .watched:
            return filterHelper.filter({ $0.watched })
        }
        
        // Filter additional attributes from LessonsFilterView
        if listFilter.watchedOnly {
            filterHelper = filterHelper.filter({$0.watched})
        }
        if listFilter.unwatchedOnly {
            filterHelper = filterHelper.filter({!$0.watched})
        }
        if listFilter.includedLessonTypesActive {
            filterHelper = filterHelper.filter({
                listFilter.includedLessonTypes.contains(Lesson.LessonType(rawValue: $0.type!) ?? .lecture)
            })
        }
        if listFilter.excludedLessonTypesActive {
            filterHelper = filterHelper.filter({
                !listFilter.excludedLessonTypes.contains(Lesson.LessonType(rawValue: $0.type!) ?? .lecture)
            })
        }
        if listFilter.includedTagsActive {
            for tag in listFilter.includedTags {
                filterHelper = filterHelper.filter({
                    ($0.tag?.contains(tag) ?? false)
                })
            }
        }
        if listFilter.excludedTagsActive {
            for tag in listFilter.excludedTags {
                filterHelper = filterHelper.filter({
                    !($0.tag?.contains(tag) ?? false)
                })
            }
        }
        
        
        // Sort the List
        switch sort {
        case .dateAscending:
            filterHelper.sort(by: {$0.date! < $1.date!})
        case .dateDescending:
            filterHelper.sort(by: {$0.date! > $1.date!})
        case .name:
            filterHelper.sort(by: {$0.title! < $1.title!})
        case .location:
            filterHelper.sort(by: {$0.location! < $1.location!})
        case .teacher:
            filterHelper.sort(by: {$0.teacher! < $1.teacher!})
        }
        
        return filterHelper
    }
    
    var isEmpty: Bool {
        return filteredLessons.isEmpty
    }
    
    // MARK: - List
    var lessonList: some View {
        List(selection: $listHelper.selection) {
            ForEach(filteredLessons, id: \.self) { lesson in
                LessonsRow(lesson: lesson)
                    .tag(lesson)
                    .contextMenu(menuItems: {
                        #if os(macOS)
                        LessonContextMenu(lesson: lesson, sheetToPresent: $sheetToPresent, deleteAlertShown: $alertShowing, lessonToDelete: $lessonToDelete)
                        #else
                        LessonContextMenu(lesson: lesson, sheetToPresent: $sheetToPresent, deleteAlert: $listHelper.deleteAlertShown)
                        #endif
                    })
            }
            .onDelete(perform: deleteItems)
        }
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            if filteredLessons.count > 0 {
                ScrollViewReader { proxy in
                    Group {
                        #if os(macOS)
                        lessonList
                            .animation(.none)
                            .onDeleteCommand(perform: {
                                lessonToDelete = listHelper.selection.first
                                alertShowing = true
                            })
                            .navigationSubtitle("\(filteredLessons.count) Lessons")
                            .listStyle(InsetListStyle())
                            .alert(isPresented: $listHelper.deleteAlertShown) {
                                Alert(title: Text("Delete Lesson"), message: Text("Are you sure you want to delete?  This action can't be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {alertShowing = false}))
                            }
                        #else
                        lessonList
                            .popover(isPresented: $listHelper.shareSheetShown) {
                                ShareSheet(isPresented: $listHelper.shareSheetShown, activityItems: [Lesson.export(lessons: Array(listHelper.selection))!])
                            }
                            .alert(isPresented: $listHelper.deleteAlertShown) {
                                Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action can't be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {listHelper.deleteAlertShown = false; listHelper.lessonToChange = nil}))
                            }
                        #endif
                    }
                    .onReceive(nc.publisher(for: .scrollToNow), perform: { _ in
                        scrollToNow(proxy: proxy)
                    })
                    .onReceive(nc.publisher(for: .scrollToOldest), perform: { _ in
                        scrollToOldest(proxy: proxy)
                    })
                    .onReceive(nc.publisher(for: .scrollToNewest), perform: { _ in
                        scrollToNewest(proxy: proxy)
                    })
                }
                .navigationTitle(titleString)
                .sheet(item: $sheetToPresent,
                       onDismiss: {
                        listHelper.lessonToChange = nil},
                       content: { item in
                    switch item {
                    case .addLesson:
                        AddLessonView(lesson: $listHelper.lessonToChange, isPresented: $listHelper.addLessonIsPresented, type: listType.lessonType ?? .lecture).environment(\.managedObjectContext, viewContext)
                    case .filter:
                        LessonsFilterView(viewShown: $listHelper.filterViewActive, listType: listType, filter: listFilter)
                            .frame(idealWidth: 600)
                    case .ilo:
                        #if os(macOS)
                        ILOGeneratorView(isPresented: $listHelper.ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                            .frame(idealWidth: 600)
                        #else
                        NavigationView {
                            ILOGeneratorView(isPresented: $listHelper.ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                        }
                        #endif
                    }
                })
            } else {
                Group {
                #if os(macOS)
                NoLessonsMessage(listType: listType)
                    .navigationTitle(titleString)
                    .navigationSubtitle("\(filteredLessons.count) Lessons")
                #else
                NoLessonsMessage(listType: listType)
                    .navigationTitle(titleString)
                #endif
                }
                .sheet(item: $sheetToPresent, onDismiss: {listHelper.lessonToChange = nil}, content: { item in
                    switch item {
                    case .addLesson:
                        AddLessonView(lesson: $listHelper.lessonToChange, isPresented: $listHelper.addLessonIsPresented, type: listType.lessonType ?? .lecture).environment(\.managedObjectContext, viewContext)
                    case .filter:
                        LessonsFilterView(viewShown: $listHelper.filterViewActive, listType: listType, filter: listFilter)
                            .frame(idealWidth: 600)
                    case .ilo:
                        #if os(macOS)
                        ILOGeneratorView(isPresented: $listHelper.ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                            .frame(idealWidth: 600)
                        #else
                        NavigationView {
                            ILOGeneratorView(isPresented: $listHelper.ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                        }
                        #endif
                    }
                })
            }
        }
        .toolbar {
            #if os(iOS)
            LessonsListToolbar(editMode: editMode!, listHelper: listHelper, listFilter: listFilter, listType: $listType, selection: $listHelper.selection, sheetToPresent: $sheetToPresent, deleteAlertShown: $listHelper.deleteAlertShown, isEmpty: isEmpty)
            #else
            LessonsListToolbar(listHelper: listHelper, listFilter: listFilter, listType: $listType, selection: $listHelper.selection, sheetToPresent: $sheetToPresent, deleteAlertShown: $alertShowing, isEmpty: isEmpty)
            #endif
        }
        .onReceive(nc.publisher(for: .exportLessons), perform: { _ in
            #if os(iOS)
            listHelper.shareSheetShown = true
            #endif
        })
        .onReceive(nc.publisher(for: .exportAll), perform: { _ in
            listHelper.selection = Set(lessons)
            listHelper.exporterShown = true
        })
        .onReceive(nc.publisher(for: .exportCurrentView), perform: { _ in
            listHelper.selection = Set(filteredLessons)
            listHelper.exporterShown = true
        })
        .onReceive(nc.publisher(for: .markILOsWritten), perform: { _ in
            guard let lesson = listHelper.selection.first else {return}
            listHelper.markOutcomesWritten(lesson)
        })
        .onReceive(nc.publisher(for: .markILOsUnwritten), perform: { _ in
            guard let lesson = listHelper.selection.first else {return}
            listHelper.markOutcomesUnwritten(lesson)
        })
        .onReceive(nc.publisher(for: .selectAll), perform: { _ in
            filteredLessons.forEach({listHelper.selection.insert($0)})
        })
    }
    
    private func deleteItems(offsets: IndexSet) {
        listHelper.lessonsToDelete.removeAll()
        offsets.map { filteredLessons[$0] }.forEach { lesson in
            listHelper.lessonsToDelete.append(lesson)
            lessonToDelete = lesson
        }
        #if os(iOS)
        listHelper.deleteAlertShown = true
        #else
        listHelper.deleteAlertShown = true
        #endif
    }
    
    private func deleteLessons() {
        print(listHelper.lessonsToDelete.count)
        withAnimation {
            listHelper.lessonsToDelete.forEach({$0.delete(context: viewContext)})
            lessonToDelete?.delete(context: viewContext)
        }
        listHelper.lessonsToDelete.removeAll()
        lessonToDelete = nil
        listHelper.selection.removeAll()
    }
    
    private func scrollToNow(proxy: ScrollViewProxy) {
        guard filteredLessons.count > 0 else { return }
        let sortedLessons = filteredLessons.sorted(by: {$0.date! < $1.date!})
        
        if let nextLesson = sortedLessons.first(where: {$0.date ?? Date(timeIntervalSince1970: 0) > Date()}) {
            withAnimation {
                #if os(macOS)
                listHelper.selection = [nextLesson]
                #else
                if horizontalSizeClass == .regular {
                    listHelper.selection = [nextLesson]
                }
                #endif
                proxy.scrollTo(nextLesson)
            }
        } else {
            withAnimation {
                let lastLesson = sortedLessons.last!
                #if os(macOS)
                listHelper.selection = [lastLesson]
                #endif
                proxy.scrollTo(lastLesson)
            }
        }
    }
    
    private func scrollToOldest(proxy: ScrollViewProxy) {
        guard filteredLessons.count > 0 else { return }
        let sortedLessons = filteredLessons.sorted(by: {$0.date! < $1.date!})
        let firstLesson = sortedLessons.first!
        withAnimation {
            proxy.scrollTo(firstLesson)
        }
    }
    
    private func scrollToNewest(proxy: ScrollViewProxy) {
        guard filteredLessons.count > 0 else { return }
        let sortedLessons = filteredLessons.sorted(by: {$0.date! < $1.date!})
        let lastLesson = sortedLessons.last!
        withAnimation {
            proxy.scrollTo(lastLesson)
        }
    }
    
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(listType: LessonsListType(filterType: .all, lessonType: nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
