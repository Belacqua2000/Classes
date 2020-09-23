//
//  ResourceSection.swift
//  Classes
//
//  Created by Nick Baughan on 18/09/2020.
//

import SwiftUI

struct ResourceSection: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var isInValidURLAlertShown: Bool = false
    @State var isAddingResource: Bool = false
    @State private var selectedResource: Resource?
    @ObservedObject var lesson: Lesson
    var resources: FetchedResults<Resource>
    
    var filteredResources: [Resource] {
        //return resources.filter { $0.lesson == lesson }
        let resources = lesson.resource?.allObjects as? [Resource] ?? []
        return resources.sorted(by: {
            $0.name ?? "" < $1.name ?? ""
        })
    }
    
    var listHeight: CGFloat {
        #if os(macOS)
        return 100
        #else
        return 200
        #endif
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if filteredResources.count > 0 {
                #if !os(macOS)
                EditButton()
                #endif
                List {
                    ForEach(filteredResources) { resource in
                        let re = resource as Resource
                        HStack {
                            Text("\(re.name ?? "No Name"):")
                            Spacer()
                            if let url = re.url {
                                Link(url.host ?? "Open Link", destination: url)
                                    .help(re.url?.absoluteString ?? "Link")
                            }
                        }
                        .contextMenu(ContextMenu(menuItems: {
                            Button(action: {
                                selectedResource = re
                                isAddingResource = true
                            }, label: {
                                Label("Edit", systemImage: "square.and.pencil")
                            })
                            Button(action: {
                                copyResourceURL(resource.url)
                            }, label: {
                                Label("Copy URL", systemImage: "doc")
                            })
                        }))
                    }
                    .onDelete(perform: deleteResources)
                    .alert(isPresented: $isInValidURLAlertShown) {
                        Alert(title: Text("Invalid URL"), message: Text("Unable to open the URL.  Please check it is correct."), dismissButton: .cancel(Text("Dismiss")))
                    }
                }
                .cornerRadius(10)
                .frame(height: listHeight)
            }
            HStack {
                Button("Add Resource", action: {isAddingResource = true})
                Spacer()
            }
            .padding(.vertical)
            .sheet(isPresented: $isAddingResource, onDismiss: {
                selectedResource = nil
            },content: {
                #if !os(macOS)
                NavigationView {
                    AddResource(resourceText: selectedResource?.name ?? "", resourceURL: selectedResource?.url?.absoluteString ?? "", isPresented: $isAddingResource, resource: $selectedResource, lesson: lesson).environment(\.managedObjectContext, viewContext)
                        .navigationTitle("Add Resource")
                }
                .navigationViewStyle(StackNavigationViewStyle())
                #else
                AddResource(resourceText: selectedResource?.name ?? "", resourceURL: selectedResource?.url?.absoluteString ?? "", isPresented: $isAddingResource, resource: $selectedResource, lesson: lesson)
                #endif
            })
        }
    }
    
    private func copyResourceURL(_ url: URL?) {
        guard let url = url else { return }
        print("Copied")
        #if os(macOS)
        //NSPasteboard.general.stri
        #else
        UIPasteboard.general.url = url
        #endif
    }
    
    private func deleteResources(offsets: IndexSet) {
        withAnimation {
            offsets.map { filteredResources[$0] }.forEach { resource in
                let resource = resource as Resource
                resource.delete(context: viewContext, save: false)
            }
            saveOnDelay()
        }
    }
    
    private func saveOnDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            do {
                try viewContext.save()
            } catch {
                print(error)
            }
        }
    }
}
