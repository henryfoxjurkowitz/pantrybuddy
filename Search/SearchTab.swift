//
//  SearchTabView.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 5/31/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI


// Tab containing the search bar and results from searching for recipes
struct SearchTab: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food> // Pass list of Foods from core data
    
    @ObservedObject var suggestor = Suggestions()       // ObservedObject that gets their suggestions
    @State var pressedButton = false                    // Keeps track of whether they have clicked the search button
    @State var searchText = ""                          // Keeps track of their search text
    @State var pageSelector: String? = nil              // Tracks the recipe they were looking at so they can switch
                                                        // tabs and come back to the recipe
    
    let recipes = Bundle.main.decode("HugeDict.json") // Get all recipes
    
    // Styles the navigation bar
    init () {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()      // Keeps navigation bar opaque when scrolling
        appearance.largeTitleTextAttributes =  [.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor(displayP3Red: 0.52, green: 0.93, blue: 0.7, alpha: 1)
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack{
                    // This search bar allows the user to input key words for their recipe suggestions
                    SearchBar(text: $searchText, placeholder: "Optional: add any key words here") // The custom search bar
                        .onAppear {
                        self.searchText = "" // Clear the search text when switching tabs
                    }
                }
                
                // Button that the user presses to see the suggested recipes
                Button("Get My Recipes!") {
                    UIApplication.shared.endEditing()
                    self.pressedButton = true
                    self.suggestor.updateSuggestions(searchText: self.searchText, foods: self.foods, recipes: self.recipes) // Update their recipe suggestions
                }
                .foregroundColor(Color(red:0.4, green: 0.69, blue: 0.52))
                .font(.system(size: 20))
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(10)
                
                // If they pressed the button and there are no results, then the search came up empty
                // This displays a message letting them know
                if self.suggestor.suggestions.isEmpty && self.pressedButton {
                    VStack {
                        Image(systemName: "cart")
                            .font(.system(size: 80))
                        Text("Our search came up empty!")
                            .padding(.top)
                        Text("Time to go shopping...")
                    }
                    .foregroundColor(.gray)
                    .padding(.top,60)
                }
                
                // If they have no results, they haven't pressed the button yet
                // This displays a message explaining how to add foods and then find recipes
                else if self.suggestor.suggestions.isEmpty {
                    VStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 80))
                        Text("Add foods to your pantry and")
                            .padding(.top)
                        Text("then find recipes here!")
                    }
                    .foregroundColor(.gray)
                    .padding(.top,60)
                }
                
                VStack {
                    // Displays the recipes that the app finds
                    ForEach(self.suggestor.suggestions){ recipe in
                        // Links to the RecipePage object for each RecipeCard
                        NavigationLink(destination: RecipePage(recipe:recipe)
                            .navigationBarTitle(Text(recipe.title), displayMode: .inline), tag: recipe.id, selection: self.$pageSelector)
                        {
                            RecipeCard(recipe: recipe,showDivider: true)
                            
                        }
                    }
                    .padding(.horizontal,15)
                }
                .padding(.top,10).padding(.bottom,5)
                .background(Color.white.cornerRadius(15)
                .padding([.bottom,.horizontal],10)
                .shadow(radius: 5))
            }
            .navigationBarTitle("Find Recipes")
            .background(
                Color(red: 0.52, green: 0.93, blue: 0.7)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all))
        }
        .accentColor(.black)
    }
}

struct SearchTabView_Previews: PreviewProvider {
    static var previews: some View {
        SearchTab()
    }
}


