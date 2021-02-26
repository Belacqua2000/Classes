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
    @Binding var selection: Set<Lesson>
    @Binding var sheetToPresent: LessonsListContent.Sheets?
    @Binding var deleteAlertShown: Bool
    var isEmpty: Bool
    
    var addLessonButton: some View {
        Button(action: {
            #if os(iOS)
            sheetToPresent = .addLesson
            #else
            sheetToPresent = .addLesson
            #endif
//            nc.post(.init(name: .newLesson))
        }, label: {
            Label("Add Lesson", systemImage: "plus")
        })
        .onReceive(nc.publisher(for: .newLesson), perform: { _ in
            sheetToPresent = .addLesson
        })
        .help("Add a New Lesson")
    }
    
    
    var scrollButton: some View {
        
        Menu(content: {
            Button(action: {
                nc.post(Notification(name: .scrollToNow))
            }, label: {
                Label("Scroll To Now", systemImage: "clock")
            })
            .help("Scroll to the next lesson in the list after now.")
            
            Button(action: {
                nc.post(Notification(name: .scrollToOldest))
            }, label: {
                Label("Scroll To Oldest", systemImage: "arrow.up.to.line")
            })
            .help("Scroll to the oldest lesson in the list.")
            
            Button(action: {
                nc.post(Notification(name: .scrollToNewest))
            }, label: {
                Label("Scroll To Newest", systemImage: "arrow.down.to.line")
            })
            .help("Scroll to the latest lesson in the list.")
            
        }, label: {
            Label("Scroll List", systemImage: "arrow.turn.right.down")
        })
        .help("Scroll to a place in the list.")
        .disabled(isEmpty)
    }
    
    var iloButton: some View {
        Button(action: {
            sheetToPresent = .ilo
        }, label: {
            Label("Generate Learning Outcomes", systemImage: "list.number")
        })
        .help("View ILOs")
        .help("View the Learning Outcome Randomiser for the current selection of lessons")
        .onReceive(nc.publisher(for: .showILORandomiser), perform: { _ in
            sheetToPresent = .ilo
        })
        .disabled(isEmpty)
    }
    
    var filterButton: some View {
        Button(action: {sheetToPresent = .filter}, label: {
            Label("Filter", systemImage: listFilter.anyFilterActive ? "line.horizontal.3.decrease.circle.fill" : "line.horizontal.3.decrease.circle")
        })
        .help("Filter Lessons in the View")
        .onReceive(nc.publisher(for: .showFilterView), perform: { _ in
            sheetToPresent = .filter
        })
    }
    
    var markCompleteMenu: some View {
        Menu(content: {
            
            // Only show option if there are lessons which are unwatched
            if selection.contains(where: {!$0.watched}) {
                Button(action: {
                    withAnimation {
                        listHelper.markWatched(lessons: Array(listHelper.selection))
                    }
                }, label: {
                    Label("Mark Completed", systemImage: "checkmark.circle")
                })
            }
            
            // Only show option if there are lessons which are watched
            if selection.contains(where: {$0.watched}) {
                Button(action: {
                    withAnimation {
                        listHelper.markUnwatched(lessons: Array(listHelper.selection))
                    }
                }, label: {
                    Label("Mark Uncompleted", systemImage: "xmark.circle")
                })
            }
            Divider()
            Button(action: {
                withAnimation {
                    Array(listHelper.selection).forEach({
                        listHelper.markOutcomesWritten($0)
                    })
                }
            }, label: {
                Label("Mark All Outcomes Achieved", systemImage: "checkmark.circle")
            })
            Button(action: {
                withAnimation {
                    Array(listHelper.selection).forEach({
                        listHelper.markOutcomesUnwritten($0)
                    })
                }
            }, label: {
                Label("Mark All Outcomes Unachieved", systemImage: "xmark.circle")
            })
        }, label: {
            Label("Mark Completed", systemImage: "checkmark.circle")
        })
        .imageScale(.large)
    }
    
    var selectMenu: some View {
        Menu(content: {
            Button("Select All", action: { nc.post(.init(name: .selectAll)) })
            Button("Deselect All", action: { listHelper.deselectAll() })
        }, label: {
            Text("Select")
        })
    }
    
    var body: some ToolbarContent {
        #if os(iOS)
        
        ToolbarItemGroup(placement: .bottomBar) {
            if editMode.isEditing == false {
                scrollButton
                Spacer()
                iloButton
                Spacer()
                filterButton
            } else {
                selectMenu
                Group {
                    Spacer()
                    Button(action: {
                        nc.post(Notification(name: .exportLessons))
                    }, label: {
                        Label("Share", systemImage: "square.and.arrow.up")
                    })
                    Spacer()
                    Button(action: {
                        listHelper.lessonsToDelete = listHelper.selection
                        deleteAlertShown = true
                    }, label: {
                        Label("Delete", systemImage: "trash")
                    })
                    Spacer()
                    markCompleteMenu
                }
                .disabled(selection.isEmpty)
            }
            Spacer()
            EditButton().animation(.default)
                .onChange(of: editMode, perform: {_ in
                    listHelper.selection.removeAll()
                    print("Removing lessons from selection")
                })
                .disabled(isEmpty)
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
        ToolbarItem(id: "AddLessonButton", placement: .primaryAction) {
            addLessonButton
        }
    }
}
