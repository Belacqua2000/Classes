//
//  ExamView.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 27/02/2021.
//

import SwiftUI

struct ExamView: View {
    
    enum exam: String, Identifiable, CaseIterable {
        var id: String { return rawValue }
        case phase1 = "Phase 1"
        case phase2 = "Phase 2"
        case phase3 = "Phase 3"
    }
    
    @State var pickerSelection: exam = .phase3
    
    var body: some View {
            ScrollView {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Exam Details:")
                            .bold()
                            .font(.system(.title, design: .rounded))
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Date: \(Date(), style: .date)")
                                Text("Topics: 30")
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color(red: 0.949, green: 0.886, blue: 0.729, opacity: 1))
                        .cornerRadius(8)
//                        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Topics:")
                                    .bold()
                                Spacer()
                                Text(Image(systemName: "line.horizontal.3.decrease.circle"))
                                    .bold()
                            }
                            .font(.system(.title, design: .rounded))
                            
                            ForEach(0..<5) { topic in
                                NavigationLink(destination: Text("")) {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("Topic \(topic + 1)")
                                                .bold()
                                            HStack {
                                                ForEach(0..<topic + 1) { topic in
                                                    Image(systemName: "star.fill")
                                                        .renderingMode(.original)
                                                }
                                            }
                                            Text("Studied \(topic) times")
                                            Text("Last studied:")
                                        }
                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color(red: 0.729, green: 0.843, blue: 0.949, opacity: 1.000))
                                    .cornerRadius(10)
                                    .foregroundColor(.primary)
                                }
                            }
                        }
                        
                    }
                    .padding(.horizontal)
                    .navigationTitle("Exam View")
//                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            Picker(
                                selection: $pickerSelection,
                                label:
                                    Text("\(pickerSelection.rawValue) \(Image(systemName: "chevron.down"))")
                                    .font(.system(.title, design: .rounded))
                                    .bold()
                                    .foregroundColor(Color(red: 0.372, green: 0.442, blue: 0.687, opacity: 1.000))
                                    .padding()
                                ,
                                content: {
                                    ForEach(exam.allCases) { exam in
                                        Text(exam.rawValue)
                                            .tag(exam)
                                    }
                                })
                                .pickerStyle(MenuPickerStyle())
                        }
                    }
                }
                Spacer()
            }
    }
}

struct ExamView_Previews: PreviewProvider {
    static var previews: some View {
        #if os(macOS)
        ExamView()
        #else
        NavigationView {
            ExamView()
        }
        .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
}
