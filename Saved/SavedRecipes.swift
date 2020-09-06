//
//  SavedRecipes.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 7/15/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

struct SavedRecipes: View {
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: SavedRecipe.entity(), sortDescriptors: []) var recipes: FetchedResults<SavedRecipe>
    
    var body: some View {
        List {
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
    //since recipeCard and recipePage take Recipe objects, this converts the SavedRecipe to a Recipe
    func getRecipeObj(rec: SavedRecipe) -> Recipe {
        Recipe(title: rec.name ?? "Unknown", rating: rec.rating ?? "Unknown", reviews: rec.numReviews ?? "Unknown", ingredientList: (rec.ingreds?.components(separatedBy: "!")) ?? [], url: rec.url ?? "Unknown", id: rec.id!.uuidString, img: rec.img ?? "Unknown")
    }
}


struct SavedRecipes_Previews: PreviewProvider {
    static var previews: some View {
        SavedRecipes()
    }
}
