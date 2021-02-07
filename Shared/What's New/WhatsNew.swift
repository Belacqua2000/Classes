//
//  WhatsNew.swift
//  Classes
//
//  Created by Nick Baughan on 22/10/2020.
//

import SwiftUI

struct WhatsNew: View {

    @Environment(\.presentationMode) var presentationMode
    struct VersionSelection: Hashable {
        let type: FeatureType
        let featureGroups: [AppVersionFeatures]
        let featureVersion: String?
        
        var string: String {
            switch type {
            case .all:
                return "All Features"
            case .unseen:
                return "Unseen Features"
            case .version:
                return "Version \(featureVersion ?? "")"
            }
        }
        
        init(type: FeatureType, versionString: String?) {
            self.type = type
            self.featureVersion = versionString
            switch type {
            case .all:
                featureGroups = AppFeatures.all.features.sorted().reversed()
            case .unseen:
                featureGroups = AppFeatures().unseenVersions.sorted().reversed()
            case .version:
                featureGroups = AppFeatures.all.featuresForVersion(versionString!)
            }
        }
        
        enum FeatureType {
            case all, unseen, version
        }
    }
    
    @State private var currentSelection: VersionSelection = VersionSelection(type: .unseen, versionString: nil)
    
    var body: some View {
        VStack {
            Text("What's New")
                .font(.largeTitle)
                .bold()
            Text("Current Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")")
                .font(.headline)
                .bold()
                .padding(.bottom, 20)
            
            HStack {
                #if os(iOS)
                VersionPicker(currentSelection: $currentSelection)
                    .padding(2)
                    .background(Color(.systemGray5))
                    .cornerRadius(5)
                    .padding()
                #else
                VersionPicker(currentSelection: $currentSelection)
                    .frame(width: 200)
                #endif
                Spacer()
            }
            
            if !currentSelection.featureGroups.isEmpty {
                /*ScrollView {
                    HStack {
                        VStack(alignment: .leading, spacing: 20) {*/
                List {
                            ForEach(currentSelection.featureGroups, id: \.self) { featureGroup in
                                Section(header:
                                    Text("Version \(featureGroup.versionString)")
                                ) {
                                ForEach(featureGroup.features, id: \.self) { feature in
                                    Label(title: {
                                        VStack(alignment: .leading) {
                                            Text(feature.title)
                                                .bold()
                                            Text(feature.details)
                                                .font(.body)
                                        }
                                    }, icon: {
                                        Image(systemName: feature.imageName)
                                            .foregroundColor(.accentColor)
                                    })
                                    .font(.title)
                                }
                                }
                            }
                        }
//                .listStyle(InsetGroupedListStyle())
                        /*}
                        Spacer()
                    }
                }*/
            } else {
                Spacer()
                Text("You are all up to speed with new app features!  Use the menu to review previous changes you may have missed.")
            }
            
            Spacer()
            #if os(iOS)
            Button(action: markSeen, label: {
                Text("Get Started")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
            })
            .cornerRadius(10)
            #else
            Button("Get Started", action: markSeen).keyboardShortcut(.defaultAction)
            #endif
        }
        .padding(.vertical)
        .navigationTitle("What's New")
        .userActivity("com.baughan.classes.open-whats-new", { activity in
            print("What's new NSUserActivity donated.")
        })
    }
    
    private func markSeen() {
        AppFeatures.all.setLastOpenedVersion()
        presentationMode.wrappedValue.dismiss()
    }
}

#if DEBUG
struct WhatsNew_Previews: PreviewProvider {
    static let file = Bundle.main.path(forResource: "AppFeatures", ofType: "json")!
    static func getData() -> Data {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: file), options: .mappedIfSafe)
            return data
        } catch {
            return Data()
        }
    }
    static var features = AppFeatures.debug(data: String(data: getData(), encoding: .utf8)!)
    static var previews: some View {
        WhatsNew()
//        Text("Root View")
//            .sheet(isPresented: .constant(true)) {
//        WhatsNew()
//            .preferredColorScheme(.light)
//            }
            
    }
}
#endif


