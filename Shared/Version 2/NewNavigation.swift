//
//  NewNavigation.swift
//  Classes
//
//  Created by Nick Baughan on 27/02/2021.
//

import SwiftUI

struct NewNavigation: View {
    
    var body: some View {
        NavigationView {
            CollectionList4()
            Version4(title: "All Topics")
//            Text("Choose Topic")
        }
    }
}

struct NewNavigation_Previews: PreviewProvider {
    static var previews: some View {
        NewNavigation()
    }
}
