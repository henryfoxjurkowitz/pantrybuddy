//
//  RecipeCard.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/15/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI
import SafariServices

// Compact recipe card to display in search results
struct RecipeCard: View {
    let recipe: Recipe              // The Recipe object for the RecipeCard to display
    let showDivider: Bool           // Adds a black line to separate cards in search tab, doesn't add a black line on last result
    @State var showSafari = false   // Allows the link in the RecipeCard to directly open Safari links
    
    // Gets all saved recipes from core data to check whether recipes are already saved
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: SavedRecipe.entity(), sortDescriptors: []) var recipes: FetchedResults<SavedRecipe>
    
    var body: some View {
        let title = recipe.title
        var rating = recipe.rating
        if rating > "5.1" {rating = "0.0"}    // means rating is "none" in JSON file, set to 0
        let reviews = recipe.reviews
        let url = recipe.url
        let img = recipe.img
        let ings = recipe.ingredientList.joined(separator: "!") // Core data can't store an array of ingredients, so they are joined using an "!", which won't be in any ingredients, allowing them to later be split by the "!"
        
        return VStack {
            HStack {
                // Recipe title
                if (title.count > 31) {
                    Text(title.prefix(31) + "...") // Cut off title if it's too long to fit
                        .font(.system(size: 15))
                } else {
                    Text(title)
                    .font(.system(size: 15))
                }
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
                        newRec.ingreds = ings
                        newRec.priority = (self.recipes.map{$0.priority}.max() ?? 0)+1
                    }
                    else {
                        // Otherwise set the priority to 0, unsaving it
                        let rec = self.recipes.first(where: {$0.name == title && $0.numReviews == reviews})!
                        rec.priority = 0
                    }
                    try? self.moc.save()
                }, label: {
                    // Label button with a filled in bookmark if saved, otherwise unfilled 
                    if recipes.contains(where: {$0.name == title && $0.numReviews == reviews && $0.priority > 0}) {
                        Image(systemName: "bookmark.fill")
                    }
                    else {
                        Image(systemName: "bookmark")
                    }
                })
                .buttonStyle(BorderlessButtonStyle())
                
                // Button that links to the recipe's actual website
                Image(systemName: "link").padding(.horizontal,10).onTapGesture {
                    self.showSafari = true
                }
                .foregroundColor(Color(red: 0.4, green: 0.69, blue: 0.54))
                .sheet(isPresented: $showSafari) {
                    SafariView(url:URL(string: url)!)
                }
            }
            
            
            HStack {
                Stars(rating: rating) // Images of stars representing how highly rated the recipe is
                Spacer()
                Text("\(reviews) Ratings") // Displays the number of ratings that this recipe has received
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
            }
            .padding(5)
            .font(.system(size: 10))
            .foregroundColor(Color(red: 0.4, green: 0.69, blue: 0.54))
            
            if showDivider {
                Divider().background(Color.black)
            }
        }.foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3)).padding(.vertical,3)
    }
}


// ViewController to open the Safari page of recipes
struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}
