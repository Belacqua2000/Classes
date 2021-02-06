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
    
    let nc = NotificationCenter.default
    
    enum Sort: String, CaseIterable, Identifiable {
        var id: String { return rawValue }
        case dateAscending = "Oldest"
        case dateDescending = "Newest"
        case name = "Name"
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
            return "Unwatched Lessons"
        case .unwritten:
            return "Unwritten Lessons"
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
    
    @State var selectedLessons: [Lesson]? // for delete actions
    @State var selectedLesson: Lesson? // for editing lesson
    
    @EnvironmentObject var listHelper: LessonsListHelper
    
    @Binding var listType: LessonsListType
    @StateObject var listFilter = LessonsListFilter()
    
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
        }
        
        return filterHelper
    }
    
    // MARK: - List
    var lessonList: some View {
        List(selection: $listHelper.selection) {
            ForEach(filteredLessons, id: \.self) { lesson in
                LessonsRow(selection: $listHelper.selection, lesson: lesson)
                    .tag(lesson)
                    .contextMenu(menuItems: {
                        LessonContextMenu(lesson: lesson)
                    })
            }
            .onDelete(perform: deleteItems)
        }
        .alert(isPresented: $listHelper.deleteAlertShown) {
            Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action cannt be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {listHelper.deleteAlertShown = false; listHelper.lessonToChange = nil}))
        }
    }
    
    var noLessonsMessage: some View {
        #if os(macOS)
        return VStack {
            Text("No Lessons.  Click the \(Image(systemName: "plus")) button in the toolbar to create one.")
                .padding()
                .navigationTitle(titleString)
                .navigationSubtitle("\(filteredLessons.count) Lessons")
        }
        #else
        return Text("No Lessons.  Press the \(Image(systemName: "plus")) button in the toolbar to create one.")
            .padding()
            .navigationTitle(titleString)
        #endif
    }
    
    // MARK: - Body
    var body: some View {
        VStack {
            if filteredLessons.count > 0 {
                #if os(macOS)
                ScrollViewReader { proxy in
                    lessonList
                        .onDeleteCommand(perform: {listHelper.deleteAlertShown = true})
                        .navigationTitle(titleString)
                        .navigationSubtitle("\(filteredLessons.count) Lessons")
                        .listStyle(InsetListStyle())
                        .onReceive(nc.publisher(for: .scrollToNow), perform: { _ in
                            scrollToNow(proxy: proxy)
                        })
                        .alert(isPresented: $listHelper.deleteAlertShown) {
                            Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action cannt be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {listHelper.deleteAlertShown = false; listHelper.lessonToChange = nil}))
                        }
                }
                #else
                ScrollViewReader { proxy in
                    lessonList
                        .navigationTitle(titleString)
                        .onReceive(nc.publisher(for: .scrollToNow), perform: { _ in
                            scrollToNow(proxy: proxy)
                        })
                        .overlay(LessonsActionButtons(selection: $listHelper.selection), alignment: .trailing)
                }
                .popover(isPresented: $listHelper.shareSheetShown) {
                    ShareSheet(isPresented: $listHelper.shareSheetShown, activityItems: [Lesson.export(lessons: Array(listHelper.selection))!])
                }
                .alert(isPresented: $listHelper.deleteAlertShown) {
                    Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action cannt be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {listHelper.deleteAlertShown = false; listHelper.lessonToChange = nil}))
                }
                .fullScreenCover(isPresented: $listHelper.ilosViewShown, content: {
                    #if os(macOS)
                    ILOGeneratorView(isPresented: $ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                    #else
                    NavigationView {
                        ILOGeneratorView(isPresented: $listHelper.ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                    }
                    #endif
                })
                #endif
            } else {
                noLessonsMessage
            }
        }
        .sheet(item: $listHelper.sheetToPresent, onDismiss: {listHelper.lessonToChange = nil}, content: { item in
            switch item {
            case .addLesson:
                AddLessonView(lesson: listHelper.lessonToChange, isPresented: $listHelper.addLessonIsPresented, type: listType.lessonType ?? .lecture).environment(\.managedObjectContext, viewContext)
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
        .onAppear(perform: {
            #if os(macOS)
            guard filteredLessons.first != nil else { return }
            listHelper.selection.insert(filteredLessons.first!)
            #endif
        })
        .fileExporter(
            isPresented: $listHelper.exporterShown,
            document: LessonJSON(lessons: Array(listHelper.selection)),
            contentType: .classesFormat,
            onCompletion: {_ in })
        .toolbar {
            LessonsListToolbar(listHelper: listHelper, listFilter: listFilter, listType: $listType)
        }
        .onReceive(nc.publisher(for: .deleteLessons), perform: { _ in
            listHelper.deleteAlertShown = true
        })
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
        
    }
    
    private func deleteItems(offsets: IndexSet) {
        offsets.map { filteredLessons[$0] }.forEach { lesson in
            listHelper.lessonToChange = lesson
            listHelper.selection = [lesson]
            listHelper.deleteAlertShown = true
        }
    }
    
    private func deleteLessons() {
        withAnimation {
            listHelper.lessonToChange?.delete(context: viewContext)
            for lesson in listHelper.selection {
                lesson.delete(context: viewContext)
            }
        }
        listHelper.lessonToChange = nil
        listHelper.selection.removeAll()
    }
    
    private func scrollToNow(proxy: ScrollViewProxy) {
        guard filteredLessons.count > 0 else { return }
        let sortedLessons = filteredLessons.sorted(by: {$0.date! < $1.date!})
        
        if let nextLesson = sortedLessons.first(where: {$0.date ?? Date(timeIntervalSince1970: 0) > Date()}) {
            withAnimation {
                #if os(macOS)
                listHelper.selection = [nextLesson]
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
    
}

struct LessonsView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsView(listType: LessonsListType(filterType: .all, lessonType: nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
