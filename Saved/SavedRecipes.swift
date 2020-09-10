//
//  SavedRecipes.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 7/15/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

// Displays all recipes that the user has saved
struct SavedRecipes: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: SavedRecipe.entity(), sortDescriptors: []) var recipes: FetchedResults<SavedRecipe> // Gets SavedRecipes from core data
    
    var body: some View {
        List {
            // Filter recipes that have priority 0 (no longer saved) and order them by priority so that they appear
            // in the order that they were saved
            ForEach(recipes.filter({$0.priority > 0}).sorted(by: {$0.priority < $1.priority}), id: \.id) { savedRec in
                NavigationLink(destination: RecipePage(recipe:self.getRecipeObj(rec: savedRec))
                    .navigationBarTitle(Text(savedRec.name ?? "Unknown"), displayMode: .inline))
                    {
                        RecipeCard(recipe: self.getRecipeObj(rec: savedRec),showDivider: false)
                }
            }
        }
        .navigationBarTitle("Saved Recipes")
    }
    
    // Since we want the user to be able to click the SavedRecipe and view it's ingredients etc., we have to convert the SavedRecipe object
    // from core data into a Recipe object, allowing us to use our RecipePage and RecipeCard views
    func getRecipeObj(rec: SavedRecipe) -> Recipe {
        Recipe(title: rec.name ?? "Unknown", rating: rec.rating ?? "Unknown", reviews: rec.numReviews ?? "Unknown", ingredientList: (rec.ingreds?.components(separatedBy: "!")) ?? [], url: rec.url ?? "Unknown", id: rec.id!.uuidString, img: rec.img ?? "Unknown")
    }
}


struct SavedRecipes_Previews: PreviewProvider {
    static var previews: some View {
        SavedRecipes()
    }
}
