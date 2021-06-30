//
//  ContentView.swift
//  WordScramble
//
//  Created by Bruce Gilmour on 2021-06-30.
//

import SwiftUI

struct ContentView: View {
    let people = ["Finn", "Leia", "Luke", "Rey"]

    var body: some View {
        altDynamicList
    }

    var mixedList: some View {
        List {
            Section(header: Text("Section 1")) {
                Text("Static row 1")
                Text("Static row 2")
            }

            Section(header: Text("Section 2")) {
                ForEach(0 ..< 5) {
                    Text("Dynamic row \($0)")
                }
            }

            Section(header: Text("Section 3")) {
                Text("Static row 3")
                Text("Static row 4")
            }
        }
        .listStyle(GroupedListStyle())
    }

    var dynamicList: some View {
        List(people, id: \.self) {
            Text($0)
        }
        .listStyle(GroupedListStyle())
    }

    var altDynamicList: some View {
        List {
            ForEach(people, id: \.self) {
                Text($0)
            }
        }
        .listStyle(GroupedListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
