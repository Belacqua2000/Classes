//
//  AppFeaturesModel.swift
//  Classes
//
//  Created by Nick Baughan on 07/02/2021.
//

import Foundation

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
        print([majorNumber,minorNumber,patchNumber])
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
        #if os(iOS)
        let filePathString = "AppFeaturesiOS"
        #else
        let filePathString = "AppFeaturesMac"
        #endif
        if let path = Bundle.main.path(forResource: filePathString, ofType: "json") {
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
