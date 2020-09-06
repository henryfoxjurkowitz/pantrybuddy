//
//  SearchBarView.swift
//  Pantry Pal
//
//  Created by Henry on 5/25/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI
import CoreData

class CreateFoodMenu: ObservableObject { // this allows me to toggle the menu from within the menu
    @Published var state = false
    
    func tog(_ newState: Bool) {
        state = newState
    }
}

class HoldSearchText: ObservableObject {
    @Published var text = ""
    
    func set(_ heldText: String) {
        text = heldText
    }
}

struct PantryTab: View {
    @ObservedObject var createFoodSwitch = CreateFoodMenu()
    @ObservedObject var heldSearchText = HoldSearchText()
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
        
    var body: some View {
        ZStack {
            PantrySearch(heldSearch: heldSearchText,createMenu: createFoodSwitch)
            if self.createFoodSwitch.state {
                CreateFoodView(menuSwitch: createFoodSwitch, text: heldSearchText.text)
                    .onDisappear(perform:
                        { self.heldSearchText.set("") }
                    )
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .background(
                        Color.black.opacity(0.65)
                            .edgesIgnoringSafeArea(.all)
                            .onTapGesture {
                                self.createFoodSwitch.tog(false)
                        }
                    )
            }
            if foods.count < 100 { // loads their foods the first time they log in
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

