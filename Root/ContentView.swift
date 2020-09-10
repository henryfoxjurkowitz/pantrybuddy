//
//  ContentView.swift
//  Pantry Pal
//
//  Created by Henry on 5/24/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    @State private var selection = 0
    
    //make tab bar background gray
    init() {
        UITabBar.appearance().backgroundColor = UIColor(displayP3Red: 0.35, green: 0.35, blue: 0.35, alpha: 1)
    }
 
    var body: some View {
        // sets up the app's four tabs
        TabView(selection: $selection){
            PantryTab()
            .tabItem {
                Image(systemName: "cart")
                Text("Pantry")
            }
            .tag(0)
            SearchTab()
                .tabItem {
                Image(systemName:"magnifyingglass")
                Text("Search")
            }
            .tag(1)
            SavedTab()
            .tabItem {
                Image(systemName: "bookmark")
                Text("Saved")
            }
            .tag(2)
        }.background(Color(red: 0.52, green: 0.93, blue: 0.7)  // make background green when switching tabs
            .edgesIgnoringSafeArea(.all))
        .accentColor(Color(red: 0.4, green: 0.69, blue: 0.54)) // sets app accent color to darker green
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
