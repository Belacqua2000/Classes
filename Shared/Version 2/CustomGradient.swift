//
//  CustomGradient.swift
//  Classes
//
//  Created by Nick Baughan on 06/03/2021.
//

import SwiftUI

struct CustomGradient: View {
    var red: CGFloat
    var orange: CGFloat
    var green: CGFloat
    
    var total: CGFloat {
        return red + orange + green
    }
    
    var body: some View {
        GeometryReader { gr in
            HStack(spacing: 0) {
                ZStack {
                    Color.red
                        .frame(width: gr.size.width * red / total)
                    Text(Int(red).description)
                }
                ZStack(alignment: .center) {
                    Color.orange
                        .frame(width: gr.size.width * orange / total)
                    Text(Int(orange).description)
                }
                ZStack {
                    Color.green
                        .frame(width: gr.size.width * green / total)
                    Text(Int(green).description)
                }
            }
            .font(.system(.footnote, design: .rounded))
        }
    }
    
}

struct CustomGradient_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomGradient(red: 1, orange: 2, green: 3)
                .frame(height: 20)
                .cornerRadius(10)
        }
        .padding()
    }
}
