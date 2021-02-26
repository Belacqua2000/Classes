//
//  NoLessonsMessage.swift
//  Classes
//
//  Created by Nick Baughan on 25/02/2021.
//

import SwiftUI

struct NoLessonsMessage: View {
    var listType: LessonsListType
    
    let image: Image = Image(systemName: "face.smiling")
    
    var supplementaryText: Text? {
        switch listType.filterType {
        case .all:
            return Text("There are no lessons yet.")
        case .tag:
            return Text("You have no lessons with this tag.")
        case .lessonType:
            switch listType.lessonType {
            case .lecture: return Text("There are no lectures.")
            case .tutorial: return Text("There are no tutorials.")
            case .pbl: return Text("There are no PBL lessons.")
            case .cbl: return Text("There are no CBL lessons.")
            case .lab: return Text("There are no labs.")
            case .clinical: return Text("There are no clinical skills lessons.")
            case .selfStudy: return Text("There are no self study items.")
            case .video: return Text("There are no videos.")
            default: return Text("You have no lessons with this lesson type.")
            }
        case .watched:
            return Text("There are no watched lessons.")
        case .today:
            return Text("You have no lessons today.")
        case .unwatched:
            return Text("Well done, you have no unwatched lessons!")
        case .unwritten:
            return Text("Well done, you have no lessons with unachieved learning outcomes!")
        }
    }
    
    let newLessonText = Text("Click the \(Image(systemName: "plus")) button in the toolbar to create a new lesson.")
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            HStack {
                Spacer()
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .foregroundColor(.accentColor)
                Spacer()
            }
            
            supplementaryText
            
            newLessonText
            Spacer()
        }
        .padding()
    }
}

struct NoLessonsMessage_Previews: PreviewProvider {
    static var previews: some View {
        NoLessonsMessage(listType: .init(filterType: .all))
    }
}
