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
        let rectShape: RoundedRectangle = RoundedRectangle(cornerRadius: 20)
        HStack {
            Image(systemName: "tag")
                .offset(x: 2)
            Text(tag.name ?? "Tag")
                .offset(x: -2)
        }
        .padding(3.0)
        .background(
            rectShape.fill(tag.swiftUIColor!.opacity(0.8))
        )
        .overlay(
            rectShape
                .stroke(tag.swiftUIColor!)
        )
        .font(.footnote)
    }
}

/*
struct TagIcon_Previews: PreviewProvider {
    static var previews: some View {
        TagIcon()
    }
}
*/
