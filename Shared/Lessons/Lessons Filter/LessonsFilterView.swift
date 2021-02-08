//
//  LessonsFilterView.swift
//  Classes
//
//  Created by Nick Baughan on 15/11/2020.
//

import SwiftUI

struct LessonsFilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var viewShown: Bool
    var listType: LessonsListType
    @ObservedObject var filter: LessonsListFilter
    
    var form: some View {
        Form {
            if listType.filterType != .unwatched && listType.filterType != .watched {
                Section(header: Label("Watched Status", systemImage: "eye")) {
                    Toggle(isOn: $filter.watchedOnly, label: {
                        Text("Watched Only")
                    })
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(filter.unwatchedOnly)
                    
                    Toggle(isOn: $filter.unwatchedOnly, label: {
                        Text("Unwatched Only")
                    })
                    .toggleStyle(SwitchToggleStyle())
                    .disabled(filter.watchedOnly)
                }
            }
            
            ILOFilterView(isPresented: $filter.iloFilterPresented, listType: listType, includedTags: $filter.includedTags, includedLessonTypes: $filter.includedLessonTypes, excludedTags: $filter.excludedTags, excludedLessonTypes: $filter.excludedLessonTypes, includedLessonTypeFilterActive: $filter.includedLessonTypesActive, excludedLessonTypeFilterActive: $filter.excludedLessonTypesActive, includedTagFilterActive: $filter.includedTagsActive, excludedTagFilterActive: $filter.excludedTagsActive)
        }
        .navigationTitle("Filter Lessons")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: {
                    presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
    
    var body: some View {
        #if os(macOS)
        form
            .padding()
        #else
        NavigationView {
            form
        }.navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}

struct LessonsFilterView_Previews: PreviewProvider {
    static var previews: some View {
        LessonsFilterView(viewShown: .constant(false), listType: LessonsListType(filterType: .all), filter: LessonsListFilter())
    }
}
