//
//  ILOsView.swift
//  Classes
//
//  Created by Nick Baughan on 08/09/2020.
//

import SwiftUI

struct ILOsView: View {
    
    private enum ViewStates: String, CaseIterable, Identifiable {
        var id: String { return rawValue }
        case list = "Browse"
        case iloRandomiser = "Outcome Randomiser"
    }
    
    @SceneStorage("ILOsView.CurrentViewState") private var currentILOView: ViewStates = .list
    
    @State private var generatorShown = false
    @State private var filterShown = false
    
    @State private var includedFilterActive = false
    @State private var currentIncludedTags = [Tag]()
    @State private var currentIncludedLessonTypes = [Lesson.LessonType]()
    @State private var excludedFilterActive = false
    @State private var currentExcludedTags = [Tag]()
    @State private var currentExcludedLessonTypes = [Lesson.LessonType]()
    
    @EnvironmentObject var randomiserShown: EnvironmentHelpers
    
    @Environment(\.managedObjectContext) var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \ILO.lesson?.date, ascending: true), NSSortDescriptor(keyPath: \ILO.index, ascending: true)],
        animation: .default)
    private var ilos: FetchedResults<ILO>
    
    private var filteredILOs: [ILO] {
        /*var ilos = Array(self.ilos)
        if includedFilterActive {
            ilos = ilos.filter({
                currentIncludedLessonTypes.contains(Lesson.LessonType(rawValue: $0.lesson!.type!) ?? .lecture)
            })
            
            for tag in currentIncludedTags {
                ilos = ilos.filter({
                    ($0.lesson?.tag?.contains(tag) ?? false)
                })
            }
        }
        
        if excludedFilterActive {
            ilos = ilos.filter({
                !currentExcludedLessonTypes.contains(Lesson.LessonType(rawValue: $0.lesson!.type!) ?? .lecture)
            })
            
            for tag in currentExcludedTags {
                ilos = ilos.filter({
                    !($0.lesson?.tag?.contains(tag) ?? false)
                })
            }
        }
         
         return ilos*/
        return ilos.filter({
            filteredLessons.contains($0.lesson!)
        })
    }
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Lesson.date, ascending: true)],
        animation: .default)
    private var lessons: FetchedResults<Lesson>
    
    private var filteredLessons: [Lesson] {
        var lessons = Array(self.lessons)
        if includedFilterActive {
            lessons = lessons.filter({
                currentIncludedLessonTypes.contains(Lesson.LessonType(rawValue: $0.type!) ?? .lecture)
            })
            
            for tag in currentIncludedTags {
                lessons = lessons.filter({
                    ($0.tag?.contains(tag) ?? false)
                })
            }
        }
        
        if excludedFilterActive {
            lessons = lessons.filter({
                !currentExcludedLessonTypes.contains(Lesson.LessonType(rawValue: $0.type!) ?? .lecture)
            })
            
            for tag in currentExcludedTags {
                lessons = lessons.filter({
                    !($0.tag?.contains(tag) ?? false)
                })
            }
        }
        
        return lessons
    }
    
    var body: some View {
        VStack {
            if ilos.count > 0 {
                /*#if !os(macOS)
                AllILOsList(lessons: Array(lessons), ilos: Array(ilos))
                Spacer()
                Button(action: {randomiserShown.iloRandomiserShown = true}, label: {Text("Randomise All Outcomes")})
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 300, height: 50)
                    .background(Color.accentColor)
                    .cornerRadius(8)
                    .padding(.bottom)
                    .fullScreenCover(isPresented: $randomiserShown.iloRandomiserShown) {
                        NavigationView {
                            ILOGeneratorView(isPresented: $generatorShown, ilos: ilos.shuffled())
                        }
                    }
                #else*/
                if currentILOView == .list {
                    AllILOsList(lessons: filteredLessons, ilos: Array(ilos))
                } else {
                    ILOGeneratorView(isPresented: .constant(true), ilos: filteredILOs.shuffled())
                }
//                #endif
            } else {
                Text("No Learning Outcomes.  Add outcomes from the lesson info page.")
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Current View", selection: $currentILOView) {
                    ForEach(ViewStates.allCases) { state in
                        Text(state.rawValue).tag(state)
                    }
                }
                .labelsHidden()
                .pickerStyle(SegmentedPickerStyle())
            }
            ToolbarItem(placement: .primaryAction) {
                Button(action: {
                    filterShown = true
                }, label: {
                    Label("Filter", systemImage: "line.horizontal.3.decrease.circle")
                })
                .help("Filter the shown outcomes by lesson type or tag")
                .sheet(isPresented: $filterShown) {
                    #if os(iOS)
                    NavigationView {
                        ILOFilterView(isPresented: $filterShown, includedTags: $currentIncludedTags, includedLessonTypes: $currentIncludedLessonTypes, excludedTags: $currentExcludedTags, excludedLessonTypes: $currentExcludedLessonTypes, includedFilterActive: $includedFilterActive, excludedFilterActive: $excludedFilterActive)
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    #else
                    ILOFilterView(isPresented: $filterShown, includedTags: $currentIncludedTags, includedLessonTypes: $currentIncludedLessonTypes, excludedTags: $currentExcludedTags, excludedLessonTypes: $currentExcludedLessonTypes, includedFilterActive: $includedFilterActive, excludedFilterActive: $excludedFilterActive)
                        .padding()
                        .frame(minWidth: 400, minHeight: 200)
                    #endif
                }
            }
        }
        .navigationTitle("Learning Outcomes")
    }
}

//.navigationSubtitle("\(ilos.count) ILOs")

struct ILOsView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(iOS)
        NavigationView {
            ILOsView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        ILOsView()
        #endif
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
