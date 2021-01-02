//
//  TagIcon.swift
//  Classes
//
//  Created by Nick Baughan on 12/09/2020.
//

import SwiftUI

struct TagIcon: View {
    var tag: Tag
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(tag.swiftUIColor!)
            HStack {
                Image(systemName: "tag")
                    .offset(x: 2)
                Text(tag.name ?? "Tag")
                    .offset(x: -2)
            }
            .foregroundColor(textColor(bgColor: tag.swiftUIColor!))
            .padding(3.0)
            .font(.footnote)
        }
    }
    
    private func textColor(bgColor: Color) -> Color {
        
        var w: CGFloat = 0.0
        var a: CGFloat = 0.0
        
        #if os(iOS)
        UIColor(bgColor).getWhite(&w, alpha: &a)
        #else
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        
        NSColor(bgColor).usingColorSpace(.sRGB)?.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        
        w = ((r * 299) + (g * 587) + (b * 114)) / 1000
//        w = (r+g+b)/3
        #endif
        
        return w < 0.5 ? .white : .black
    }
}


struct TagIcon_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let tag = Tag(context: context)
        tag.name = "Tag Name"
        return TagIcon(tag: tag).environment(\.managedObjectContext, context)
    }
}

