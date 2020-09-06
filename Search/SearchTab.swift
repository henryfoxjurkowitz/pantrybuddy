//
//  SearchTabView.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 5/31/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

struct SearchTab: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
    
    @ObservedObject var suggestor = Suggestions()       // keeps track of suggestions for them
    @State var pressedButton = false                    // keeps track of whether they have searched for recipes
    @State var searchText = ""                          // keeps track of their search text
    @State var pageSelector: String? = nil              // keeps track of what food page they're on
    
    let recipes = Bundle.main.decode("HugeDict.json")
    
    // styles the navigation bar
    init () {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.largeTitleTextAttributes =  [.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor(displayP3Red: 0.52, green: 0.93, blue: 0.7, alpha: 1)
        
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().standardAppearance = appearance
        
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack{ // to allow the searchbar padding
                    SearchBar(text: $searchText, placeholder: "Optional: add any key words here")
                        .onAppear {
                        self.searchText = "" // clears the search text when switching tabs
                    }
                }
                
                Button("Get My Recipes!") {
                    UIApplication.shared.endEditing()
                    self.pressedButton = true
                    self.suggestor.updateSuggestions(searchText: self.searchText, foods: self.foods, recipes: self.recipes)
                }
                .foregroundColor(Color(red:0.4, green: 0.69, blue: 0.52))
                .font(.system(size: 20))
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding(10)
                
                if self.suggestor.suggestions.isEmpty && self.pressedButton { // we found nothing message
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
                else if self.suggestor.suggestions.isEmpty { // they haven't searched yet message
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
                    ForEach(self.suggestor.suggestions){ recipe in
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


