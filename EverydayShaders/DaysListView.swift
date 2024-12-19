//
//  ListView.swift
//  EverydayShaders
//
//  Created by Alex Shepard on 12/19/24.
//

import SwiftUI

struct DaysListView: View {
    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    ContentView_20241219()
                } label: {
                    Text("Dec 19 2024")
                }
            }
        } detail: {
            Text("Select a day")
        }
    }
}

#Preview {
    DaysListView()
}
