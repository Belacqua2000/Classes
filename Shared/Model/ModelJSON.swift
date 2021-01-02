//
//  ModelJSON.swift
//  Classes
//
//  Created by Nick Baughan on 23/09/2020.
//

import SwiftUI
import UniformTypeIdentifiers
import CoreData

struct LessonJSON: FileDocument, Codable {
    static var readableContentTypes: [UTType] = [.classesFormat]
    
    // MARK:- Initialisers
    
    // Reads the file opened in the app
    init(configuration: ReadConfiguration) throws {
        // Check can access data from the file and can correctly decode it.
        guard let data = configuration.file.regularFileContents,
              let jsonLessons = try? JSONDecoder().decode(LessonJSON.self, from: data)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self = jsonLessons
    }
    
    // Encodes the data to a file
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        let fw = FileWrapper(regularFileWithContents: data)
        fw.filename = "Lessons Backup - \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))"
        return fw
    }
    
    // Creates the data from given lessons
    init(lessons: [Lesson]) {
        var data = [LessonData]()
        for lesson in lessons {
            data.append(LessonData(lesson: lesson))
        }
        lessonData = data
    }
    
    // Creates the data from given lessons
    init?(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            
            guard let jsonLessons = try? JSONDecoder().decode(LessonJSON.self, from: data) else {
                return nil
            }
            
            self = jsonLessons
            
            
            
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    var version: Int = 2
    
    let lessonData: [LessonData]

    // MARK:- Underlying LessonData Struct and initialisers
    struct LessonData: Codable, Hashable {
        /*static func == (lhs: LessonJSON.LessonData, rhs: LessonJSON.LessonData) -> Bool {
            return
                lhs.date == rhs.date &&
                lhs.title == rhs.title &&
                lhs.notes == rhs.notes &&
                lhs.teacher == rhs.teacher &&
                lhs.location == rhs.location &&
                lhs.type == rhs.type &&
                lhs.watched == rhs.watched
                
        }*/
        
        let date: Date?
        let location: String?
        let notes: String?
        let teacher: String?
        let title: String?
        let type: String?
        let watched: Bool
        
        let ilo: [ILOJSON]
        
        let resource: [ResourceJSON]
        
        init(lesson: Lesson) {
            date = lesson.date
            location = lesson.location
            notes = lesson.notes
            teacher = lesson.teacher
            title = lesson.title
            type = lesson.type
            watched = lesson.watched
            
            var ilos = [ILOJSON]()
            if let lessonILOs = lesson.ilo?.allObjects as? [ILO] {
            for ilo in lessonILOs {
                ilos.append(ILOJSON(index: ilo.index, title: ilo.title ?? "Untitled", written: ilo.written))
            }
            }
            ilo = ilos
            
            var resources = [ResourceJSON]()
            if let lessonResources = lesson.resource?.allObjects as? [Resource] {
            for resource in lessonResources {
                resources.append(ResourceJSON(name: resource.name ?? "Untitled", url: resource.url))
            }
            }
            resource = resources
        }
        
        struct ILOJSON: Codable, Hashable {
            let index: Int16
            let title: String
            let written: Bool
        }
        
        struct ResourceJSON: Codable, Hashable {
            let name: String
            let url: URL?
        }
        
        // Converts the data to Lessons
        func createLesson(context: NSManagedObjectContext) {
                let createdLesson = Lesson(context: context)
                createdLesson.id = UUID()
                createdLesson.title = title
                createdLesson.type = type
                createdLesson.teacher = teacher
                createdLesson.date = date
                createdLesson.location = location
                createdLesson.watched = watched
                createdLesson.notes = notes
                
                for ilo in ilo {
                    let createdILO = ILO(context: context)
                    createdILO.id = UUID()
                    createdILO.index = ilo.index
                    createdILO.title = ilo.title
                    createdILO.written = ilo.written
                    createdLesson.addToIlo(createdILO)
                }
                
                for resource in resource {
                    let createdResource = Resource(context: context)
                    createdResource.id = UUID()
                    createdResource.name = resource.name
                    createdResource.url = resource.url
                    createdLesson.addToResource(createdResource)
                }
                
                do {
                    try context.save()
                } catch {
                    print(error.localizedDescription)
                }
        }
        
    }
    
}
