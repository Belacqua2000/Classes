//
//  ImportView.swift
//  Classes
//
//  Created by Nick Baughan on 24/09/2020.
//

import SwiftUI

struct ImportView: View {
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
//    @Binding var isPresented: Bool
    @Binding var url: URL?
    @Binding var lessonsInFile: LessonJSON?
    @State var lessonsToBeImported = [LessonJSON.LessonData]()
    
    @State var imported = false
    @State private var alertShown = false
    
    #if os(macOS)
    private let alignment: HorizontalAlignment = .leading
    #else
    private let alignment: HorizontalAlignment = .center
    #endif
    
    var body: some View {
        VStack(alignment: alignment, spacing: 20) {
                #if os(macOS)
                Text("Import Lessons")
                    .font(.title)
                    .bold()
                #endif
                if lessonsInFile != nil {
                    Text("\(lessonsInFile?.lessonData.count ?? 0) Lessons found in the file.")
                    
                    List(lessonsInFile?.lessonData ?? [], id: \.self) { lesson in
                        HStack {
                            VStack(alignment: .leading) {
                                Label(lesson.title ?? "Untitled Lesson", systemImage: Lesson.lessonIcon(type: lesson.type))
                                Text(lesson.date ?? Date(), style: .date)
                                    .font(.footnote)
                            }
                            Spacer()
                            Button(action: {
                                addOrRemoveImportList(lesson)
                            }, label: {
                                lessonsToBeImported.contains(lesson) ?
                                    Image(systemName: "checkmark.circle.fill") : Image(systemName: "checkmark.circle")
                            })
                        }
                    }
                    VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Button("Select All", action: selectAll)
                            .disabled(lessonsToBeImported.count == lessonsInFile?.lessonData.count)
                        Button("Deselect All", action: deselectAll)
                            .disabled(lessonsToBeImported.isEmpty)
                    }
                    Text("\(lessonsToBeImported.count) lessons selected.").bold()
                    Text("Please note, if any of these lessons are already in the app, they will be reimported.").italic()
                    }
                } else {
                    Spacer()
                    Text("Unable to read lessons from the file.")
                        .bold()
                        .font(.title)
                    Spacer()
                }
                #if os(iOS)
                Button(action: showAlert, label: {
                    Text("Import")
                        .padding(20)
                        .frame(width: 200)
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                })
                .buttonStyle(BorderlessButtonStyle())
                .cornerRadius(10)
                .disabled(url == nil || imported == true || lessonsToBeImported.isEmpty)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                if imported {
                    Text("Lessons have been imported")
                }
        }.padding()
        .frame(idealWidth: 600, idealHeight: 300)
            .alert(isPresented: $alertShown, content: {
                Alert(
                    title: Text("Confirm Import"),
                    message: Text("Are you sure you want to import?  This will duplicate any lessons that you are importing which are already in Classes."),
                    primaryButton: .destructive(Text("Import"), action: addLessons),
                    secondaryButton: .cancel(Text("Cancel"), action: {alertShown = false}))
            })
            .padding(.horizontal)
            .navigationTitle("Import Lessons")
            .toolbar(id: "ImportToolbar") {
                
                #if os(macOS)
                ToolbarItem(id: "macOSImportButton", placement: .confirmationAction) {
                    Button("Import", action: showAlert)
                        .disabled(lessonsToBeImported.isEmpty || lessonsInFile == nil)
                }
                
                ToolbarItem(id: "macOSDismissButton", placement: .cancellationAction) {
                    Button("Cancel", action: dismissView)
                }
                #endif
                
                #if os(iOS)
                ToolbarItem(id: "iOSDismissButton", placement: .confirmationAction) {
                    Button("Done", action: dismissView)
                }
                #endif
                
            }
    }
    
    private func addOrRemoveImportList(_ lesson: LessonJSON.LessonData) {
        if let index =  lessonsToBeImported.firstIndex(of: lesson) {
            lessonsToBeImported.remove(at: index)
        } else {
            lessonsToBeImported.append(lesson)
        }
    }
    
    private func selectAll() {
        deselectAll()
        for lesson in lessonsInFile!.lessonData {
            lessonsToBeImported.append(lesson)
        }
    }
    
    private func deselectAll() {
        lessonsToBeImported.removeAll()
    }
    
    private func showAlert() {
        alertShown = true
    }
    
    private func addLessons() {
        
        for lesson in lessonsToBeImported {
            lesson.createLesson(context: viewContext)
        }
        
        imported = true
        
        #if os(macOS)
        dismissView()
        #endif
    }
    
    private func dismissView() {
        presentationMode.wrappedValue.dismiss()
    }
}

struct ImportView_Previews: PreviewProvider {
//    static var url = Bundle.main.url(forResource: "filePathString", withExtension: "classesdoc")
    static let lessons = LessonJSON(url: Bundle.main.url(forResource: "SampleExport", withExtension: "classesdoc")!)
    static var previews: some View {
        Group {
            ImportView(url: .constant(nil), lessonsInFile: .constant(nil))
            ImportView(url: .constant(URL(string: "wwww.nickbaughanapps.wordpress.com")), lessonsInFile: .constant(lessons))
        }
    }
}
