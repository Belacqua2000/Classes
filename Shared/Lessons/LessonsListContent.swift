//
//  LessonsListContent.swift
//  Classes
//
//  Created by Nick Baughan on 06/09/2020.
//

import SwiftUI

struct LessonsListContent: View {
    
    @State private var statsShown = false
    @State private var addLessonShown = false
    @State private var ilosViewShown = false
    @State private var filterViewActive = false
    @State private var deleteAlertShown = false
    @State private var exporterShown = false
    
    @State private var sheetPresented = false
    @State private var sheetToPresent: Sheets?
    
    private enum Sheets: String, Identifiable {
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
            return("Tag: \(listType.tag?.name ?? "")")
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
    
    @Binding var selection: Set<Lesson>
    
    @State var selectedLessons: [Lesson]? // for delete actions
    @State var selectedLesson: Lesson? // for editing lesson
    
    @EnvironmentObject var viewStates: LessonsStateObject
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
        List(selection: $selection) {
            ForEach(filteredLessons, id: \.self) { lesson in
                LessonsRow(selection: $selection, lesson: lesson)
                    .tag(lesson)
                    .contextMenu(menuItems: /*@START_MENU_TOKEN@*/{
                        Button(action: {
                            let lesson = lesson as Lesson
                            viewStates.lessonToChange = lesson
                            sheetToPresent = .addLesson
                        }, label: {
                            Label("Edit", systemImage: "square.and.pencil")
                        }).keyboardShortcut("E", modifiers: .command)
                        Divider()
                        Button(action: {toggleWatched(lessons: [lesson])}, label: {
                            !lesson.watched ? Label("Mark Watched", systemImage: "checkmark.circle")
                                : Label("Mark Unwatched", systemImage: "checkmark.circle")
                        }).keyboardShortcut("Y", modifiers: .command)
                        
                        Button(action: {
                            guard let lesson = selection.first else {return}
                            markAllOutcomes(written: true, lesson: lesson)
                        }, label: {
                            Label("Mark Outcomes as Written", systemImage: "checkmark.circle")
                        }).keyboardShortcut("D", modifiers: .command)
                        
                        Button(action: {
                            guard let lesson = selection.first else {return}
                            markAllOutcomes(written: false, lesson: lesson)
                        }, label: {
                            Label("Mark outcomes as Unwritten", systemImage: "xmark.circle")
                        }).keyboardShortcut("U", modifiers: .command)
                        
                        Divider()
                        #if os(iOS)
                        Menu(content: {
                            Button(action: {
                                #if os(iOS)
                                selection = [lesson]
                                viewStates.shareSheetShown = true
                                #else
                                viewStates.shareSheetShown = true
                                #endif
                            }, label: {
                                Label("Share", systemImage: "square.and.arrow.up")
                            })
                            
                            Button(action: {
                                #if os(iOS)
                                selection = [lesson]
                                exporterShown = true
                                #else
                                exporterShown = true
                                #endif
                            }, label: {
                                Label("Save to Files", systemImage: "folder")
                            })
                        }, label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        })
                        #else
                        Button(action: {
                            #if os(iOS)
                            selection = [lesson]
                            viewStates.shareSheetShown = true
                            #else
                            exporterShown = true
                            #endif
                        }, label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                        })
                        #endif
                        Button(action: {
                            selection = [lesson]
                            deleteAlertShown = true
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
        VStack {
            if filteredLessons.count > 0 {
                #if os(macOS)
                ScrollViewReader { proxy in
                    lessonList
                        .onDeleteCommand(perform: {deleteAlertShown = true})
                        .navigationTitle(titleString)
                        .navigationSubtitle("\(filteredLessons.count) Lessons")
                        .listStyle(InsetListStyle())
                        .onReceive(nc.publisher(for: .scrollToNow), perform: { _ in
                            scrollToNow(proxy: proxy)
                        })
                        .alert(isPresented: $deleteAlertShown) {
                            Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action cannt be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {deleteAlertShown = false; viewStates.lessonToChange = nil}))
                        }
                }
                #else
                ScrollViewReader { proxy in
                    lessonList
                        .navigationTitle(titleString)
                        .onReceive(nc.publisher(for: .scrollToNow), perform: { _ in
                            scrollToNow(proxy: proxy)
                        })
                        .overlay(LessonsActionButtons(selection: $selection), alignment: .trailing)
                }
                .popover(isPresented: $viewStates.shareSheetShown) {
                    ShareSheet(isPresented: $viewStates.shareSheetShown, activityItems: [Lesson.export(lessons: Array(selection))!])
                }
                .alert(isPresented: $deleteAlertShown) {
                    Alert(title: Text("Delete Lesson(s)"), message: Text("Are you sure you want to delete?  This action cannt be undone."), primaryButton: .destructive(Text("Delete"), action: deleteLessons), secondaryButton: .cancel(Text("Cancel"), action: {deleteAlertShown = false; viewStates.lessonToChange = nil}))
                }
                #endif
            } else {
                #if os(macOS)
                VStack {
                    Text("No Lessons.  Click the \(Image(systemName: "plus")) button in the toolbar to create one.")
//                        .fixedSize(horizontal: false, vertical: true)
                        .padding()
                        .navigationTitle(titleString)
                        .navigationSubtitle("\(filteredLessons.count) Lessons")
                }
                #else
                Text("No Lessons.  Press the \(Image(systemName: "plus")) button in the toolbar to create one.")
                    .padding()
                    .navigationTitle(titleString)
                #endif
            }
        }
        .sheet(item: $sheetToPresent, onDismiss: {viewStates.lessonToChange = nil}, content: { item in
            switch item {
            case .addLesson:
                AddLessonView(lesson: viewStates.lessonToChange, isPresented: $viewStates.addLessonIsPresented, type: listType.lessonType ?? .lecture).environment(\.managedObjectContext, viewContext)
            case .filter:
                LessonsFilterView(viewShown: $filterViewActive, listType: listType, filter: listFilter)
                    .frame(idealWidth: 600)
            case .ilo:
                #if os(macOS)
                ILOGeneratorView(isPresented: $ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                    .frame(idealWidth: 600)
                #else
                NavigationView {
                    ILOGeneratorView(isPresented: $ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                }
                #endif
            }
        })
        .onAppear(perform: {
            #if os(macOS)
            guard filteredLessons.first != nil else { return }
            selection.insert(filteredLessons.first!)
            #endif
        })
//        .sheet(isPresented: $addLessonShown,
//               onDismiss: {
//                viewStates.lessonToChange = nil
//               }, content: {
//                AddLessonView(lesson: viewStates.lessonToChange, isPresented: $viewStates.addLessonIsPresented, type: listType.lessonType ?? .lecture).environment(\.managedObjectContext, viewContext)
//               })
//        .sheet(isPresented: $ilosViewShown, content: {
//            #if os(macOS)
//            ILOGeneratorView(isPresented: $ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
//            #else
//            NavigationView {
//                ILOGeneratorView(isPresented: $ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
//            }
//            #endif
//        })
//        .sheet(isPresented: $filterViewActive, content: {
//            LessonsFilterView(viewShown: $filterViewActive, listType: listType, filter: listFilter)
//                .frame(idealWidth: 600)
//        })
        .fileExporter(
            isPresented: $exporterShown,
            document: LessonJSON(lessons: Array(selection)),
            contentType: .classesFormat,
            onCompletion: {_ in })
        .toolbar(id: "MainToolbar") {
            #if !os(macOS)
            // BOTTOM BAR BREAKS IN STACKNAVIGATIONVIEWSTYLE
            /*ToolbarItemGroup(placement: .bottomBar) {
                BottomToolbar(selection: $selection, lessonCount: filteredLessons.count)*/
            ToolbarItem(id: "ScrollNowButton", placement: .bottomBar) {
                Button(action: {
                    nc.post(Notification(name: .scrollToNow))
                }, label: {
                    Label("Scroll To Now", systemImage: "calendar.badge.clock")
                })
                .help("Scroll to the next lesson in the list after now.")
            }
            
            ToolbarItem(id: "Spacer", placement: .bottomBar) {
                Spacer()
            }
            
            ToolbarItem(id: "ILO", placement: .bottomBar) {
                Button(action: {ilosViewShown = true}, label: {
                    Label("Generate Learning Outcomes", systemImage: "doc")
                })
                .help("View Statistics")
                .fullScreenCover(isPresented: $ilosViewShown, content: {
                    #if os(macOS)
                    ILOGeneratorView(isPresented: $ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                    #else
                    NavigationView {
                        ILOGeneratorView(isPresented: $ilosViewShown, ilos: filteredLessons.flatMap({$0.ilo!.allObjects as! [ILO]}))
                    }
                    #endif
                })
            }
            
//            ToolbarItem(id: "Stats", placement: .bottomBar) {
//                Button(action: {statsShown = true}, label: {
//                    Label("View Statistics", systemImage: "chart.pie")
//                })
//                .help("View Statistics")
//                .sheet(isPresented: $statsShown) {
//                    NavigationView {
//                        SummaryView(lessons: filteredLessons)
//                    }
//                }
//
//            }
            
            ToolbarItem(id: "Spacer", placement: .bottomBar) {
                Spacer()
            }
            
            ToolbarItem(id: "Filter", placement: .bottomBar) {
                Button(action: {filterViewActive = true}, label: {
                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                })
                .help("Filter Lessons in the View")
                .sheet(isPresented: $filterViewActive) {
                    NavigationView {
                        LessonsFilterView(viewShown: $filterViewActive, listType: listType, filter: listFilter)
                    }
                }
            }
            
            #else
            
            ToolbarItem(id: "ScrollNowButton", placement: .automatic) {
                Button(action: {
                    nc.post(Notification(name: .scrollToNow))
                }, label: {
                    Label("Scroll To Now", systemImage: "calendar.badge.clock")
                })
                .help("Scroll to the next lesson in the list after now.")
            }
            
            ToolbarItem(id: "ILO", placement: .automatic) {
                Button(action: {nc.post(.init(name: .showILORandomiser))}, label: {
                    Label("Learning Outcome Randomiser", systemImage: "doc")
                })
                .help("View the Learning Outcome Randomiser for the current selection of lessons")
                .onReceive(nc.publisher(for: .showILORandomiser), perform: { _ in
                    sheetToPresent = .ilo
                })
            }
//            ToolbarItem(id: "Stats", placement: .automatic) {
//                Button(action: {statsShown = true}, label: {
//                    Label("View Statistics", systemImage: "chart.pie")
//                })
//                .help("View Statistics")
//                .sheet(isPresented: $statsShown) {
//                    SummaryView(lessons: filteredLessons)
//                }
//            }
            
            ToolbarItem(id: "Filter", placement: .automatic) {
                Button(action: {nc.post(.init(name: .showFilterView))}, label: {
                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                })
                .help("Filter the lessons in the list")
                .onReceive(nc.publisher(for: .showFilterView), perform: { _ in
                    sheetToPresent = .filter
                })
            }
            
            #endif
            
                ToolbarItem(id: "AddLessonButton", placement: .primaryAction) {
                    Button(action: {nc.post(.init(name: .newLesson))}, label: {
                        Label("Add Lesson", systemImage: "plus")
                    })
                    .onReceive(nc.publisher(for: .newLesson), perform: { _ in
                        sheetToPresent = .addLesson
                    })
                    .help("Add a New Lesson")
                }
        }
        .onReceive(nc.publisher(for: .deleteLessons), perform: { _ in
            deleteAlertShown = true
        })
        .onReceive(nc.publisher(for: .exportLessons), perform: { _ in
            #if os(iOS)
            viewStates.shareSheetShown = true
            #endif
        })
        .onReceive(nc.publisher(for: .exportAll), perform: { _ in
            selection = Set(lessons)
            exporterShown = true
        })
        .onReceive(nc.publisher(for: .exportCurrentView), perform: { _ in
            selection = Set(filteredLessons)
            exporterShown = true
        })
        .onReceive(nc.publisher(for: .markILOsWritten), perform: { _ in
            guard let lesson = selection.first else {return}
            markAllOutcomes(written: true, lesson: lesson)
        })
        .onReceive(nc.publisher(for: .markILOsUnwritten), perform: { _ in
            guard let lesson = selection.first else {return}
            markAllOutcomes(written: false, lesson: lesson)
        })
        
    }
    
    private func addLesson() {
        self.addLessonShown = true
//        viewStates.addLessonIsPresented = true
    }
    
    private func deleteItems(offsets: IndexSet) {
        offsets.map { filteredLessons[$0] }.forEach { lesson in
            viewStates.lessonToChange = lesson
            selection = [lesson]
            deleteAlertShown = true
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
    
    private func markAllOutcomes(written: Bool, lesson: Lesson) {
        if written {
            lesson.markAllILOsWritten(context: viewContext)
        } else {
            lesson.markAllILOsUnwritten(context: viewContext)
        }
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
        LessonsView(listType: LessonsListType(filterType: .all, lessonType: nil))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
