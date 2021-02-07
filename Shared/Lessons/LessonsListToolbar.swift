//
//  LessonsListToolbar.swift
//  Classes
//
//  Created by Nick Baughan on 06/02/2021.
//

import SwiftUI

struct LessonsListToolbar: ToolbarContent {
    #if os(iOS)
    @Binding var editMode: EditMode
    #endif
    let nc = NotificationCenter.default
    
    @ObservedObject var listHelper: LessonsListHelper
    @ObservedObject var listFilter: LessonsListFilter
    @Binding var listType: LessonsListType
    
    var addLessonButton: some View {
        Button(action: {listHelper.sheetToPresent = .addLesson}, label: {
            Label("Add Lesson", systemImage: "plus")
        })
        .onReceive(nc.publisher(for: .newLesson), perform: { _ in
            listHelper.sheetToPresent = .addLesson
        })
        .help("Add a New Lesson")
    }
    
    var scrollButton: some View {
        Button(action: {
            nc.post(Notification(name: .scrollToNow))
        }, label: {
            Label("Scroll To Now", systemImage: "calendar.badge.clock")
        })
        .help("Scroll to the next lesson in the list after now.")
    }
    
    var iloButton: some View {
        Button(action: {listHelper.sheetToPresent = .ilo}, label: {
            Label("Generate Learning Outcomes", systemImage: "list.number")
        })
        .help("View ILOs")
        .help("View the Learning Outcome Randomiser for the current selection of lessons")
        .onReceive(nc.publisher(for: .showILORandomiser), perform: { _ in
            //            sheetToPresent = .ilo
        })
    }
    
    var filterButton: some View {
        Button(action: {listHelper.sheetToPresent = .filter}, label: {
            Label("Filter", systemImage: listFilter.anyFilterActive ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
        })
        .help("Filter Lessons in the View")
        .sheet(isPresented: $listHelper.filterViewActive) {
            NavigationView {
                LessonsFilterView(viewShown: $listHelper.filterViewActive, listType: listType, filter: listFilter)
            }
        }
        .onReceive(nc.publisher(for: .showFilterView), perform: { _ in
            //            sheetToPresent = .filter
        })
    }
    
    var markCompleteMenu: some View {
        Menu(content: {
            Button(action: {
                withAnimation {
                    listHelper.toggleWatched(lessons: Array(listHelper.selection))
                }
            }, label: {
                Label("Toggle Completed", systemImage: "checkmark.circle")
            })
            Button(action: {
                withAnimation {
                    listHelper.toggleWatched(lessons: Array(listHelper.selection))
                }
            }, label: {
                Label("Mark Completed", systemImage: "checkmark.circle")
            })
            Button(action: {
                withAnimation {
                    listHelper.toggleWatched(lessons: Array(listHelper.selection))
                }
            }, label: {
                Label("Mark Uncompleted", systemImage: "xmark.circle")
            })
            Button(action: {
                withAnimation {
                    Array(listHelper.selection).forEach({
                        listHelper.markOutcomesWritten($0)
                    })
                }
            }, label: {
                Label("Mark All Learning Outcomes as Achieved", systemImage: "checkmark.circle")
            })
            Button(action: {
                withAnimation {
                    Array(listHelper.selection).forEach({
                        listHelper.markOutcomesUnwritten($0)
                    })
                }
            }, label: {
                Label("Mark Learning Outcomes as Not Achieved", systemImage: "xmark.circle")
            })
        }, label: {
            Label("Mark Completed", systemImage: "checkmark.circle")
        })
        .imageScale(.large)
    }
    
    var body: some ToolbarContent {
        
        ToolbarItem(id: "AddLessonButton", placement: .primaryAction) {
            addLessonButton
        }
        
        #if os(iOS)
        
        ToolbarItemGroup(placement: .bottomBar) {
            if editMode.isEditing == false {
                scrollButton
                Spacer()
                iloButton
                Spacer()
                filterButton
            } else {
                Group {
                    Button(action: {
                        nc.post(Notification(name: .exportLessons))
                    }, label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    })
                    Spacer()
                    Button(action: {
                        nc.post(Notification(name: .deleteLessons))
                    }, label: {
                        Label("Delete", systemImage: "trash")
                    })
                    Spacer()
                    markCompleteMenu
                }
//                .disabled(listHelper.selection.isEmpty)
//                .onAppear(perform: {
//                    listHelper.selection.removeAll()
//                })
//                .onDisappear(perform: {
//                    listHelper.selection.removeAll()
//                })
            }
            Spacer()
            EditButton().animation(.default)
                .onChange(of: editMode, perform: {_ in
                    listHelper.selection.removeAll()
                })
        }
        
        #else
        
        ToolbarItem(id: "ScrollNowButton", placement: .automatic) {
            scrollButton
        }
        
        ToolbarItem(id: "ILO", placement: .automatic) {
            iloButton
        }
        
        ToolbarItem(id: "Filter", placement: .automatic) {
            filterButton
        }
        
        #endif
    }
}
