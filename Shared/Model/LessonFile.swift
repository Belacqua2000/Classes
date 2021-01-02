//
//  LessonFile.swift
//  Classes
//
//  Created by Nick Baughan on 06/11/2020.
//

import SwiftUI
import UniformTypeIdentifiers

struct LessonFile: FileDocument {
    static var readableContentTypes: [UTType] { [UTType.classesFormat] }
    
    var url: String
    
    init(url: String) {
        print(url)
        self.url = url
    }
    
    init(configuration: ReadConfiguration) throws {
        
        url = ""
        
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        
        let file = try FileWrapper(url: URL(fileURLWithPath: url), options: .immediate)
        
        file.filename = "Classes Lesson Backup"
        
        return file
    }
    
    
}
