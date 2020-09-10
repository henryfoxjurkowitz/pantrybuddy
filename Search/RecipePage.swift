//
//  RecipePage.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 7/1/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

// Ingred object conforms to Identifiable so that we can easily list ingredients
struct Ingred: Identifiable {
    var id = UUID()
    var ing: String
}

// Full page to see recipe's picture and ingredients
struct RecipePage: View {
    
    let recipe: Recipe              // The Recipe object for the RecipePage to display
    @State var showSafari = false   // Allows the link in the RecipePage to directly open Safari links
    
    // Gets all saved recipes from core data to check whether recipes are already saved
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: SavedRecipe.entity(), sortDescriptors: []) var recipes: FetchedResults<SavedRecipe>
    
    var body: some View {
        let title = recipe.title
        var rating = recipe.rating
        if rating > "5.1" {rating = "0.0"} // means rating is "none" in JSON file, set to 0
        let reviews = recipe.reviews
        let url = recipe.url
        let img = recipe.img
        
        // Core data can't store an array of ingredients, so they are joined using an "!", which won't be in any ingredients, allowing them to later be split by the "!"
        let ingsToSave = recipe.ingredientList.joined(separator: "!")
        
        // Convert ingredients to Ingred objects for easy listing
        var ingreds: [Ingred] = []
        for ing in recipe.ingredientList{
            ingreds.append(Ingred(ing: ing))
        }
        
        return ScrollView {
            VStack (alignment: .leading) {
                // Display image if it is not empty
                if !img.isEmpty {
                    ZStack {
                        ImgLoader(urlString: img)
                            .opacity(0.55)
                            .background(LinearGradient(gradient: Gradient(colors: [.white, .black]), startPoint: .top, endPoint: .bottom)) // Create background gradient
                        VStack {
                            Spacer()
                            HStack {
                                // Display title of recipe overlayed on image
                                Text(title)
                                    .font(.title)
                                    .padding()
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }
                else {
                    // If there's no image, just display the recipe name
                    Text(title)
                        .font(.title)
                        .padding([.leading,.top])
                        .foregroundColor(Color(red: 0.4, green: 0.69, blue: 0.52))
                    Spacer()
                }
                HStack {
                    Spacer()
                    
                    // Button for user to save the recipe
                    Button(action: {
                        if !self.recipes.contains(where: {$0.name == title && $0.numReviews == reviews}) { // If this recipe is not saved, save it
                            let newRec = SavedRecipe(context: self.moc)
                            newRec.id = UUID()
                            newRec.name = title
                            newRec.rating = rating
                            newRec.numReviews = reviews
                            newRec.url = url
                            newRec.img = img
                            newRec.ingreds = ingsToSave
                            newRec.priority = (self.recipes.map{$0.priority}.max() ?? 0)+1
                        }
                        else {
                            // Otherwise set priority to 0, unsaving it
                            let rec = self.recipes.first(where: {$0.name == title && $0.numReviews == reviews})!
                            rec.priority = 0
                        }
                        try? self.moc.save()
                    }, label: {
                        // Label button with a filled bookmark if saved, otherwise unfilled
                        if recipes.contains(where: {$0.name == title && $0.numReviews == reviews && $0.priority > 0}) { // if it is  saved
                            Image(systemName: "bookmark.fill")
                        }
                        else {
                            Image(systemName: "bookmark")
                        }
                    })
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(Color.black)
                
                    // Button that links to the recipe's actual website
                    Image(systemName: "link").padding(.horizontal,10).onTapGesture {
                        self.showSafari = true
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.69, blue: 0.54))
                    .sheet(isPresented: $showSafari) {
                        SafariView(url:URL(string: url)!)
                    }
                    
                    Spacer()
                }
                .font(.system(size: 20))
                .padding(.top)
                .buttonStyle(BorderlessButtonStyle())
                
                HStack {
                    Stars(rating:rating) // Images of stars representing how highly rated the recipe is
                    Text("  \(reviews) Ratings") // Displays the number of ratings that this recipe has received
                    Spacer()
                }
                .padding(.all)
                .font(.system(size: 18))
                
                // List out the ingredients in the recipe
                Text("Ingredients: ")
                    .font(.title)
                    .padding([.leading,.bottom])
                ForEach (ingreds){ ing in
                    Text(ing.ing)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
        }
    }
}
