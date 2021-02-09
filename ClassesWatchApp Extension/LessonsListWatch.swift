//
//  LessonsListWatch.swift
//  ClassesWatchApp Extension
//
//  Created by Nick Baughan on 08/02/2021.
//

import SwiftUI

struct LessonsListWatch: View {
    
    var listType: LessonsListType = .init(filterType: .all)
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)], animation: .default)
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
        
        // Sort the List
        filterHelper.sort(by: {$0.date! < $1.date!})
        
        return filterHelper
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
    
    @State private var alertPresented: Bool = false
    let alert = {Alert(title: Text("No Lessons"), message: Text("Lessons can be created from other devices and will sync to your watch automatically via iCloud.  If your lessons are not appearing, please ensure iCloud is enabled on all of your devices.  If you still have trouble, please contact support."), dismissButton: .default(Text("Dismiss")))}
    
    var body: some View {
        if !filteredLessons.isEmpty {
            ScrollViewReader { proxy in
                List(filteredLessons, id: \.self) { lesson in
                NavigationLink(
                    destination: LessonDetailsWatch(lesson: lesson),
                    label: {
                        Label(title: {
                            VStack(alignment: .leading) {
                                Text(lesson.title ?? "Untitled")
                                
                                Text(DateFormatter.localizedString(from: lesson.date!, dateStyle: .short, timeStyle: .short))
                                    .font(.footnote)
                            }
                        },
                        icon: {
                            Image(systemName: Lesson.lessonIcon(type: lesson.type))})
                    })
                    .tag(lesson)
            }
            .navigationTitle("All Lessons")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: {scrollToNow(proxy: proxy)}, label: {
                        Label("Scroll To Now", systemImage: "arrow.turn.right.down")
                    })
                    .help("Scroll to the next lesson in the list after now.")
                }
            }
            }
        } else {
            VStack {
                Text("There are no lessons in this view.  Lessons can be added on iPhone, iPad and Mac.")
                
                Button("Learn More", action: showAlert)
                    .alert(isPresented: $alertPresented, content: alert)
            }
                .navigationTitle(titleString)
        }
    }
    
    private func showAlert() {
        alertPresented = true
    }
    
    private func scrollToNow(proxy: ScrollViewProxy) {
        guard !filteredLessons.isEmpty else { return }
        let sortedLessons = filteredLessons.sorted(by: {$0.date! < $1.date!})
        
        if let nextLesson = sortedLessons.first(where: {$0.date ?? Date(timeIntervalSince1970: 0) > Date()}) {
            withAnimation {
                proxy.scrollTo(nextLesson)
            }
        } else {
            withAnimation {
                let lastLesson = sortedLessons.last!
                proxy.scrollTo(lastLesson)
            }
        }
    }
    
}

struct LessonsListWatch_Previews: PreviewProvider {
    static var previews: some View {
        LessonsListWatch()
    }
}
