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
    static let scrollToOldest = Notification.Name("scrollToOldest")
    static let scrollToNewest = Notification.Name("scrollToNewest")
    static let exportLessons = Notification.Name("exportLessons")
    static let showFilterView = Notification.Name("showFilterView")
    static let showILORandomiser = Notification.Name("showILORandomiser")
    
    static let newLesson = Notification.Name("newLesson")
    static let importLessons = Notification.Name("importLessons")
    static let exportAll = Notification.Name("ExportAll")
    static let exportCurrentView = Notification.Name("ExportCurrentView")
    
    static let editLesson = Notification.Name("editLesson")
    static let addILO = Notification.Name("addILO")
    static let addResource = Notification.Name("addResource")
    static let toggleWatched = Notification.Name("toggleWatched")
    static let tagAllocateViewShown = Notification.Name("tagAllocateViewShown")
    static let markILOsWritten = Notification.Name("markILOsWatched")
    static let markILOsUnwritten = Notification.Name("markILOsUnwatched")
    
    static let detailShowing = Notification.Name("detailShowing")
    static let detailNotShowing = Notification.Name("detailNotShowing")
    
    static let showWhatsNew = Notification.Name("showWhatsNew")
    static let onboarding = Notification.Name("onboarding")
    static let selectAll = Notification.Name("selectAll")
}
