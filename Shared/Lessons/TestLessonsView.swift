//
//  TestLessonsView.swift
//  Classes
//
//  Created by Nick Baughan on 23/02/2021.
//

import SwiftUI

struct TestLessonsView: View {
    let columns = [GridItem(.adaptive(minimum: 300), alignment: .top)]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(0 ..< 5) { item in
                    VStack(alignment: .leading) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Lesson \(item)")
                                    .font(.system(.headline, design: .rounded))
                                Text("Date")
                                Text("Tags:")
                            }
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.accentColor)
                        }
                        DisclosureGroup("Learning Outcomes") {
                            HStack {
                                Text("Outcome 1")
                                Spacer()
                            }
                            Text("Outcome 2")
                        }
                    }
                    .padding()
                    .background(Color.white.cornerRadius(8).shadow(radius: 10))
                    
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .toolbar {
            Button("Add", action: {})
        }
        .navigationTitle(Text("Lessons").font(.system(.largeTitle, design: .rounded)))
    }
}

struct TestLessonsView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            NavigationView {
                TestLessonsView()
            }
            NavigationView {
                Text("List")
                TestLessonsView()
            }
            .previewDevice(.init(rawValue: "iPad Pro (11-inch) (2nd generation)"))
        }
    }
}
