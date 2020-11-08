//
//  ILOFilterView.swift
//  Classes
//
//  Created by Nick Baughan on 25/10/2020.
//

import SwiftUI

struct ILOFilterView: View {
    @Binding var isPresented: Bool
    @Environment(\.presentationMode) var presentationMode
    @Namespace private var animation
    
    #if os(macOS)
    let gridItem: [GridItem] = [GridItem(.flexible())]
    #else
    let gridItem: [GridItem] = [GridItem(.flexible())]
    #endif
    
    @FetchRequest(entity: Tag.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Tag.name, ascending: true)])
    var allTags: FetchedResults<Tag>
    
    var allLessonTypes = Lesson.LessonType.allCases
    
    @Binding var includedTags: [Tag]
    @Binding var includedLessonTypes: [Lesson.LessonType]
    
    @Binding var excludedTags: [Tag]
    @Binding var excludedLessonTypes: [Lesson.LessonType]
    
    @Binding var includedLessonTypeFilterActive: Bool
    @Binding var excludedLessonTypeFilterActive: Bool
    
    @Binding var includedTagFilterActive: Bool
    @Binding var excludedTagFilterActive: Bool
    
    var body: some View {
        ScrollView(.vertical) {
            
            // Included Lesson Types
            VStack(alignment: .leading) {
                Toggle(isOn: $includedLessonTypeFilterActive, label: {
                    Text("Include Only These Lesson Types:")
                        .font(.title)
                        .bold()
                })
                .toggleStyle(SwitchToggleStyle())
                ScrollView(.horizontal) {
                    LazyHGrid(rows: gridItem, content: {
                        ForEach(allLessonTypes) { type in
                            Button(action: {
                                selectedLessonTypeToInclude(type)
                            }, label: {
                                FilterILOPill(text: type.rawValue, image: Lesson.lessonIcon(type: type.rawValue), color: .accentColor, selected: includedLessonTypes.contains(type))
                            })
                            .buttonStyle(BorderlessButtonStyle())
                            .disabled(!includedLessonTypeFilterActive)
                        }
                    })
                }
            }
            
            VStack(alignment: .leading) {
                Toggle(isOn: $includedTagFilterActive, label: {
                    Text("Include Only These Tags:")
                        .font(.title)
                        .bold()
                })
                .toggleStyle(SwitchToggleStyle())
                ScrollView(.horizontal) {
                    LazyHGrid(rows: gridItem, content: {
                        ForEach(allTags) { tag in
                            let tag = tag as Tag
                            Button(action: {
                                selectedTagToInclude(tag)
                            }, label: {
                                FilterILOPill(text: tag.name!, image: "tag", color: tag.swiftUIColor!, selected: includedTags.contains(tag))
                            })
                            .buttonStyle(BorderlessButtonStyle())
                            .disabled(!includedTagFilterActive)
                        }
                    })
                }
            }
            
            //Included Tags
            
            Divider()
            
            
            //Excluded Lesson Types
            VStack(alignment: .leading) {
                Toggle(isOn: $excludedLessonTypeFilterActive, label: {
                    Text("Exclude These Lesson Types:")
                        .font(.title)
                        .bold()
                })
                .toggleStyle(SwitchToggleStyle())
                ScrollView(.horizontal) {
                    LazyHGrid(rows: gridItem, content: {
                        ForEach(allLessonTypes) { type in
                            Button(action: {
                                selectedLessonTypeToExclude(type)
                            }, label: {
                                FilterILOPill(text: type.rawValue, image: Lesson.lessonIcon(type: type.rawValue), color: .accentColor, selected: excludedLessonTypes.contains(type))
                            })
                            //                                .scaleEffect(excludedLessonTypes.contains(type) ? 2 : 1)
                            .buttonStyle(BorderlessButtonStyle())
                            .disabled(!excludedLessonTypeFilterActive)
                        }
                    })
                }
            }
            
            // Excluded Tags
            VStack(alignment: .leading) {
                Toggle(isOn: $excludedTagFilterActive, label: {
                    Text("Exclude These Tags:")
                        .font(.title)
                        .bold()
                })
                .toggleStyle(SwitchToggleStyle())
                ScrollView(.horizontal) {
                    LazyHGrid(rows: gridItem, content: {
                        ForEach(allTags) { tag in
                            let tag = tag as Tag
                            Button(action: {
                                selectedTagToExclude(tag)
                            }, label: {
                                FilterILOPill(text: tag.name!, image: "tag", color: tag.swiftUIColor!, selected: excludedTags.contains(tag))
                            })
                            .buttonStyle(BorderlessButtonStyle())
                            .disabled(!excludedTagFilterActive)
                        }
                    })
                }
            }
            
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: {
                    isPresented = false
                })
            }
        }
        .navigationTitle("Learning Outcome Filter")
    }
    
    private func selectedTagToInclude(_ tag: Tag) {
        withAnimation {
            if let index = excludedTags.firstIndex(of: tag) {
                excludedTags.remove(at: index)
            }
            
            if let index = includedTags.firstIndex(of: tag) {
                includedTags.remove(at: index)
            } else {
                includedTags.append(tag)
            }
        }
    }
    
    private func selectedLessonTypeToInclude(_ type: Lesson.LessonType) {
        withAnimation {
            // if already selected in excluded section, deselect it there
            if let index = excludedLessonTypes.firstIndex(of: type) {
                excludedLessonTypes.remove(at: index)
            }
            
            if let index = includedLessonTypes.firstIndex(of: type) {
                includedLessonTypes.remove(at: index)
            } else {
                includedLessonTypes.append(type)
            }
        }
    }
    
    private func selectedTagToExclude(_ tag: Tag) {
        withAnimation {
            if let index = includedTags.firstIndex(of: tag) {
                includedTags.remove(at: index)
            }
            
            if let index = excludedTags.firstIndex(of: tag) {
                excludedTags.remove(at: index)
            } else {
                excludedTags.append(tag)
            }
        }
    }
    
    private func selectedLessonTypeToExclude(_ type: Lesson.LessonType) {
        withAnimation {
            // if already selected in included section, deselect it there
            if let index = includedLessonTypes.firstIndex(of: type) {
                includedLessonTypes.remove(at: index)
            }
            
            // if already selected, deselect
            if let index = excludedLessonTypes.firstIndex(of: type) {
                excludedLessonTypes.remove(at: index)
            } else {
                excludedLessonTypes.append(type)
            }
        }
    }
}

struct ILOFilterView_Previews: PreviewProvider {
    @State static var selectedLessonTypes = [Lesson.LessonType]()
    static var previews: some View {
        #if os(iOS)
        NavigationView {
            ILOFilterView(isPresented: .constant(true), includedTags: .constant([]), includedLessonTypes: $selectedLessonTypes, excludedTags: .constant([]), excludedLessonTypes: .constant([]), includedLessonTypeFilterActive: .constant(false), excludedLessonTypeFilterActive: .constant(false), includedTagFilterActive: .constant(false), excludedTagFilterActive: .constant(false))
                .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        ILOFilterView(isPresented: .constant(true), includedTags: .constant([]), includedLessonTypes: $selectedLessonTypes, excludedTags: .constant([]), excludedLessonTypes: .constant([]), includedLessonTypeFilterActive: .constant(false), excludedLessonTypeFilterActive: .constant(false), includedTagFilterActive: .constant(false), excludedTagFilterActive: .constant(false))
            .padding()
        #endif
        //            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct FilterILOPill: View {
    var text: String
    var image: String
    var color: Color
    var selected: Bool
    #if os(macOS)
    var mac: Bool = false
    #else
    var mac: Bool = false
    #endif
    var body: some View {
        Label(
            title: { Text(text) },
            icon: { Image(systemName: image) }
        )
        .foregroundColor(.primary)
        .padding(mac ? 5 : 10)
        .background(selected ? color : .gray)
        .cornerRadius(10)
    }
}
