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
    
    var unselectedLessonTypes: [Lesson.LessonType] {
        return allLessonTypes.filter({!includedLessonTypes.contains($0)})
    }
    
    var unselectedTags: [Tag] {
        return allTags.filter({!includedTags.contains($0)})
    }
    
    @Binding var includedTags: [Tag]
    @Binding var includedLessonTypes: [Lesson.LessonType]
    
    @Binding var excludedTags: [Tag]
    @Binding var excludedLessonTypes: [Lesson.LessonType]
    
    @Binding var includedFilterActive: Bool
    @Binding var excludedFilterActive: Bool
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                VStack(alignment: .leading) {
                    Toggle(isOn: $includedFilterActive, label: {
                        Text("Include Only These Tags:")
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
//                                .scaleEffect(includedLessonTypes.contains(type) ? 2 : 1)
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(!includedFilterActive)
                            }
                            ForEach(allTags) { tag in
                                let tag = tag as Tag
                                Button(action: {
                                    selectedTagToInclude(tag)
                                }, label: {
                                    FilterILOPill(text: tag.name!, image: "tag", color: tag.swiftUIColor!, selected: includedTags.contains(tag))
                                })
//                                .scaleEffect(includedTags.contains(tag) ? 2 : 1)
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(!includedFilterActive)
                            }
                        })
                    }
                }.frame(height: gr.size.height * 0.5)
                
                Divider()
                
                VStack(alignment: .leading) {
                    Toggle(isOn: $excludedFilterActive, label: {
                        Text("Exclude These Tags:")
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
                                .disabled(!excludedFilterActive)
                            }
                            ForEach(allTags) { tag in
                                let tag = tag as Tag
                                Button(action: {
                                    selectedTagToExclude(tag)
                                }, label: {
                                    FilterILOPill(text: tag.name!, image: "tag", color: tag.swiftUIColor!, selected: excludedTags.contains(tag))
                                })
//                                .scaleEffect(excludedTags.contains(tag) ? 2 : 1)
                                .buttonStyle(BorderlessButtonStyle())
                                .disabled(!excludedFilterActive)
                            }
                        })
                    }
                }.frame(height: gr.size.height * 0.5)
                
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
            ILOFilterView(isPresented: .constant(true), includedTags: .constant([]), includedLessonTypes: $selectedLessonTypes, excludedTags: .constant([]), excludedLessonTypes: .constant([]), includedFilterActive: .constant(false), excludedFilterActive: .constant(false))
                .padding()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #else
        ILOFilterView(isPresented: .constant(true), includedTags: .constant([]), includedLessonTypes: $selectedLessonTypes, excludedTags: .constant([]), excludedLessonTypes: .constant([]), includedFilterActive: .constant(false), excludedFilterActive: .constant(false))
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
        .cornerRadius(5)
    }
}
