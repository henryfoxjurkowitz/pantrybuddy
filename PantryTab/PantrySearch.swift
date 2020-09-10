//
//  PantrySearch.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 7/16/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

struct PantrySearch: View {
    var heldSearch: HoldSearchText // gets passed the object holding search text so that it can update the text when the user types
    var createMenu: CreateFoodMenu // gets passed the object to toggle the CreateFoodMenu so that the user can create new food
                                   // from within their search
    
    @State var searchText = "" // State variable holding their current search's text
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food> // gets the Food list from core data
    
    var body: some View {
        NavigationView{
            ScrollView {
                    HStack {
                        SearchBar(text: $searchText, placeholder: "Add a food to your pantry")  // custom search bar
                    } .onAppear {
                        self.searchText = ""
                    }
                
                // if they have typed anything, display the results for the search
                if !self.searchText.isEmpty {
                    VStack {
                        HStack {
                            Spacer()
                            Button("Enter new food!") {     // Button to open CreateFoodMenu
                                self.heldSearch.set(self.searchText)
                                self.createMenu.tog(true)
                                self.searchText = ""
                                UIApplication.shared.endEditing()
                            }
                            .padding()
                            .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                            .cornerRadius(15)
                            
                            Spacer()
                        }
                        
                        // display the search results by filtering for foods that contain the search text
                        ForEach(foods.filter({($0.name ?? "Unknown").localizedCaseInsensitiveContains(self.searchText)}), id:\.self) { food in
                            HStack {
                                Text(food.name ?? "Unknown")
                                Spacer()
                                Image(systemName: "plus.circle")
                                    .onTapGesture {
                                        food.priority = (self.foods.map{$0.priority}.max() ?? 0)+1
                                        try? self.moc.save()
                                        self.searchText = ""
                                        UIApplication.shared.endEditing(true)
                                }
                            }
                        }.foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        
                        // if there are no search results, ask them to create a new food
                        if foods.filter({($0.name ??
                            "Unknown").localizedCaseInsensitiveContains(self.searchText)}).isEmpty {
                            Text("We don't have what you're looking for...").padding(.top)
                            HStack {
                                Spacer()
                                Text("Add it!")
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .padding()
                }
                
                // if they haven't typed anything, display the items in their pantry
                else {
                    PantryItemsView().background(Color(red: 0.52, green: 0.93, blue: 0.7)).padding(.vertical)
                }
            }
            .background(Color(red: 0.52, green: 0.93, blue: 0.7))
            .navigationBarTitle("My Pantry")
        }
    }
}

struct PantrySearch_Previews: PreviewProvider {
    static var previews: some View {
        PantrySearch(heldSearch: HoldSearchText(), createMenu: CreateFoodMenu())
    }
}


extension UIApplication {
    func endEditing(_ force: Bool) {
        self.windows
            .filter{$0.isKeyWindow}
            .first?
            .endEditing(force)
    }
}
