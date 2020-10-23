//
//  WhatsNew.swift
//  Classes
//
//  Created by Nick Baughan on 22/10/2020.
//

import SwiftUI

struct WhatsNew: View {
//    @Binding var isShowing: Bool
    @Environment(\.presentationMode) var presentationMode
    private struct VersionSelection: Hashable {
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
                featureGroups = AppFeatures.all.features
            case .unseen:
                featureGroups = AppFeatures().unseenVersions
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
                Picker(selection: $currentSelection,
                       label:
                        HStack {
                            Text(currentSelection.string)
                            Image(systemName: "chevron.down")
                        }
                        .padding(5)
                        .background(Color(.systemGray5))
                        .cornerRadius(5)
                ) {
                    Text("Unseen Features").tag(VersionSelection(type: .unseen, versionString: nil))
//                    Text("All Features").tag(VersionSelection(type: .all, versionString: nil))
                    ForEach(AppFeatures.all.features, id: \.self) { version in
                        Text(version.versionString).tag(VersionSelection(type: .version, versionString: version.versionString))
                    }
                }.animation(nil)
                .pickerStyle(MenuPickerStyle())
                Spacer()
            }
            
            if !currentSelection.featureGroups.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(currentSelection.featureGroups, id: \.self) { featureGroup in
                            if currentSelection.type != .version {
                                Text("Version \(featureGroup.versionString)")
                                    .font(.headline)
                                    .underline()
                            }
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
            } else {
                Spacer()
                Text("You are all up to speed with new app features!  Use the menu to review previous changes you may have missed.")
            }
            
            Spacer()
            
            Button(action: markSeen, label: {
                Text("Get Started")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
            })
            .cornerRadius(10)
        }
        .padding()
        .navigationTitle("What's New")
    }
    
    private func markSeen() {
        AppFeatures.all.setLastOpenedVersion()
        presentationMode.wrappedValue.dismiss()
    }
}

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
        //WhatsNew(unseenFeatures: features.features)
        WhatsNew()
    }
}

struct AppFeatures {
    let lastOpenedVersion: [String: Any] = UserDefaults.standard.dictionary(forKey: "lastOpenedVersion") ?? ["majorNumber": 0, "minorNumber": 0, "patchNumber": 0]
    
    func setLastOpenedVersion() {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let numbers = appVersion.split(separator: ".")
        let majorNumber = Int(numbers[0])
        let minorNumber = Int(numbers[1])
        let patchNumber: Int = numbers.count == 3 ? Int(numbers[2]) ?? 0 : 0
        
        let dict = ["majorNumber": majorNumber, "minorNumber": minorNumber, "patchNumber": patchNumber]
        let ud = UserDefaults.standard
        ud.setValue(dict, forKey: "lastOpenedVersion")
    }
    
    static let all = AppFeatures()
    
    let features: [AppVersionFeatures]
    
    func featuresForVersion(_ version: String) -> [AppVersionFeatures] {
        return self.features.filter({$0.versionString == version})
    }
    
    var unseenVersions: [AppVersionFeatures] {
        // Set the default values to version 1.2.0.  This is the last version before addition of the What's New page.
        let majorNumber = lastOpenedVersion["majorNumber"] as? Int ?? 1
        let minorNumber = lastOpenedVersion["minorNumber"] as? Int ?? 2
        let patchNumber = lastOpenedVersion["patchNumber"] as? Int ?? 0
        print(majorNumber)
        let currentVersionFeatures = AppVersionFeatures(majorNumber: majorNumber, minorNumber: minorNumber, patchNumber: patchNumber, features: [])
        
        return self.features.filter({ $0 > currentVersionFeatures})
    }
    
    #if DEBUG
    static func debug(data: String) -> AppFeatures {
        return AppFeatures(data: data)
    }
    init(data: String) {
        let data = data.data(using: .utf8)
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode([AppVersionFeatures].self, from: data!)
            features = decoded
        } catch {
            print(error.localizedDescription)
            features = []
        }
    }
    #endif
    
    init() {
        print("here")
        if let path = Bundle.main.path(forResource: "AppFeatures", ofType: "json") {
            let decoder = JSONDecoder()
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let decoded = try decoder.decode([AppVersionFeatures].self, from: data)
                features = decoded.sorted()
            } catch {
                print(error.localizedDescription)
                features = []
            }
        } else {
            features = []
        }
    }
}

struct AppVersionFeatures: Hashable, Codable, Comparable {
    static func < (lhs: AppVersionFeatures, rhs: AppVersionFeatures) -> Bool {
        if lhs.majorNumber != rhs.majorNumber {
            return lhs.majorNumber < rhs.majorNumber
        } else if lhs.minorNumber != rhs.minorNumber {
            return lhs.minorNumber < rhs.minorNumber
        } else {
            return lhs.patchNumber < rhs.patchNumber
        }
    }
    
    var majorNumber: Int
    var minorNumber: Int
    var patchNumber: Int
    
    var versionString: String {
        return [String(majorNumber),String(minorNumber),String(patchNumber)].joined(separator: ".")
    }
    
    let features: [AppFeature]
}

struct AppFeature: Hashable, Codable {
    var title: String
    var details: String
    var imageName: String
}

