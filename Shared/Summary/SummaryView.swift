//
//  SummaryView.swift
//  Classes
//
//  Created by Nick Baughan on 13/09/2020.
//

import SwiftUI

struct SummaryView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appViewState: AppViewState
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
//        animation: .default)
//    private var lessons: FetchedResults<Lesson>
    var lessons: [Lesson]
    
    @State var addLessonViewShown = false
    @State private var detailShown = false
    
    var todaysLessons: [Lesson] {
        let calendar = Calendar.current
        return lessons.filter({calendar.isDateInToday($0.date!)})
    }
    
    var overdueLessons: [Lesson] {
        return lessons.filter({$0.date! < Date() && !$0.watched})
    }
    
    func relativeDate(lesson: Lesson) -> Text {
        if lesson.date! < Date() {
            return Text("\(lesson.title ?? "No Title"): in \(lesson.date!, style: .relative)")
        } else {
            return Text("\(lesson.title ?? "No Title"):\(lesson.date!, style: .relative) ago")
        }
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.lesson?.date, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    
    var overdueILOs: [ILO] {
        return ilos.filter({$0.lesson!.date! < Date() && !$0.written})
    }
    
    var lessonsWithOverdueILOs: [Lesson] {
        return lessons.filter({($0.ilo?.allObjects as! [ILO]).contains(where: {!$0.written})})
    }
    
    var writtenILOs: Int {
        let ilos = self.ilos.filter({$0.written && $0.lesson!.date! < Date()})
        return ilos.count
    }
    
    var previousILOs: Int {
        let ilos = self.ilos.filter({$0.lesson!.date! < Date()})
        return ilos.count
    }
    
    var gridItem: [GridItem] = [GridItem(.adaptive(minimum: 300), spacing: 20, alignment: .top)]
    
    
    
    var body: some View {
            ScrollView {
                LazyVGrid(columns: gridItem, alignment: .leading, spacing: 20) {
                    TodaysLessonsView(detailShown: $detailShown, todaysLessons: todaysLessons)
                    UnwatchedLessonsList(overdueLessons: overdueLessons)
                    UnwrittenNotesList(ilos: Array(ilos), previousILOs: previousILOs, writtenILOs: writtenILOs, lessonsWithOverdueILOs: lessonsWithOverdueILOs, overdueILOsCount: overdueILOs.count)
                    StatisticsView(lessonsCount: lessons.count, ilosCount: ilos.count)
                }
                .padding(.all)
            }
            .toolbar(id: "SummaryViewToolbar") {
                ToolbarItem(id: "Dismiss", placement: .confirmationAction) {
                    Button(action: {presentationMode.wrappedValue.dismiss()}, label: {
                        Text("Close")
                    })
                }
            }
            .sheet(isPresented: $addLessonViewShown) {
                AddLessonView(lesson: nil, isPresented: $addLessonViewShown)
            }
            .navigationTitle("Summary")
            .onAppear(perform: {
                appViewState.currentTab = .summary
            })
            .background(LinearGradient(gradient: Gradient(colors: [.init("SecondaryColorLight"), .init("SecondaryColor")]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea([.bottom, .horizontal]))
        }
        //.navigationViewStyle(StackNavigationViewStyle())
    
    private let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()
}

struct SummaryView_Previews: PreviewProvider {
    static var previews: some View {
        #if !os(macOS)
        Group {
            SummaryView(lessons: [])
                .previewDevice(PreviewDevice(rawValue: "iPhone 11"))
            SummaryView(lessons: [])
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch) (2nd generation)"))
        }
        #else
        SummaryView(lessons: [])
        #endif
    }
}
