//
//  Notifications.swift
//  Classes
//
//  Created by Nick Baughan on 02/10/2020.
//

import Foundation

extension Notification.Name {
    static let showSummary = Notification.Name("showSummary")
    static let showAll = Notification.Name("showAll")
    static let showILOs = Notification.Name("showILOs")
    
    static let scrollToNow = Notification.Name("scrollToNow")
    static let deleteLessons = Notification.Name("deleteLessons")
    static let exportLessons = Notification.Name("exportLessons")
    
    static let newLesson = Notification.Name("newLesson")
}
