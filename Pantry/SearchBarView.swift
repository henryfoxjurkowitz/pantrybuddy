//
//  SearchBarView.swift
//  Pantry Pal
//
//  Created by Henry on 5/25/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI
import CoreData

// ObservableObject that allows CreateFoodMenu to open/close while inside the menu or outside of it
class CreateFoodMenu: ObservableObject {
    @Published var state = false
    
    func tog(_ newState: Bool) {
        state = newState
    }
}

// ObservableObject that holds the search text so that once the CreateFoodMenu opens,
// the placeholder text can be their search text so far
class HoldSearchText: ObservableObject {
    @Published var text = ""
    
    func set(_ heldText: String) {
        text = heldText
    }
}

// The view for the pantry tab, where the user searches and adds
// ingredients from their pantry
struct PantryTab: View {
    @ObservedObject var createFoodSwitch = CreateFoodMenu()  // creates object that tracks if CreateFoodMenu is open
    @ObservedObject var heldSearchText = HoldSearchText()    // creates object to store search text
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>    // gets the Food list from core data
        
    var body: some View {
        ZStack {
            PantrySearch(heldSearch: heldSearchText,createMenu: createFoodSwitch) // sets up search bar, results, and pantry listing
            
            if self.createFoodSwitch.state {
                // displays menu for user to add a custom food to their pantry
                CreateFoodView(menuSwitch: createFoodSwitch, text: heldSearchText.text)
                    .onDisappear(perform:
                        { self.heldSearchText.set("") } // when they are done creating the food, we reset heldSearchText
                    )
                    // gray out the rest of the screen
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(
                        Color.black.opacity(0.65)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                self.createFoodSwitch.tog(false)
                        }
                    )
            }
            if foods.count < 1 { // loads their foods the first time they log in, otherwise foods list will be populated
                // Creates a view that blocks the screen while foods load, only takes a few seconds
                LoaderView()
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .font(.system(size: 20))
                    .background(Color.black.opacity(0.65).edgesIgnoringSafeArea(.all))
            }
        }
    .onAppear(perform: {
        print(self.foods)
    })
        .background(
            Color(red:0.52, green: 0.93, blue: 0.7).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all))
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        PantryTab()
    }

}

