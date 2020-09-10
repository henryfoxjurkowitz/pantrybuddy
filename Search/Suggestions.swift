//
//  Suggestions.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 7/19/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import Foundation
import SwiftUI

class Suggestions: ObservableObject {
    @Published var suggestions: [Recipe] = [] // list of suggested receipes
    
    var keywords: [String: [String]] = [:]  // Stores keywords that prevent common matching errors
    
    // Updates the published list of recipe suggestions
    func updateSuggestions(searchText: String, foods: FetchedResults<Food>, recipes: [Recipe]) {
        keywords = createKeywordDict()  // Creates dictionary of common match errors
        var recs = recipes              // Store list of all recipes in a variable that we can modify
        if !searchText.isEmpty {recs = recipes.filter({$0.title.localizedCaseInsensitiveContains(searchText)})} // If they put in search text, only include recipes that contain the text
        
        let pantryItems = foods.filter({$0.priority > 0})      // Foods that are in the pantry
        let sideFoods: [String] = pantryItems.filter({!$0.mainFood}).map({$0.name?.lowercased() ?? ""}) // Maps to names of non-main foods
        let mainFoods: [String] = pantryItems.filter({$0.mainFood}).map({$0.name?.lowercased() ?? ""})  // Maps to names of main foods

        var scores:[Double] = [0.0] // List of scores for easy recipe sorting
        suggestions = []            // Clear any suggestions in the list
        var minScore = 0.0          // Represents how closely a recipe needs to match the search to be suggested,
                                    // will be modified as the search continues
        
        // Loop over all recipes
        for ind in 0..<recs.count {
            let rec = recs[ind]
            var numMains = 0  // Number of main foods in both pantry and recipe
            
            // Adds to the score for each main ingredient contained in both the recipe and the user's pantry
            for food in mainFoods {
                for ing in rec.ingredientList {
                    if ing.contains(food) {
                        let key = keywords.index(forKey: food)
                        // Checks if the match is a common matching error, otherwise adds to score
                        if key == nil || !(keywords[key!].value.contains(where: {ing.contains($0)})){
                            numMains+=1
                            break
                        }
                    }
                }
            }
            
            var numSides = 0  // Number of side foods in both pantry and recipe
            
            // Adds to the score for each main ingredient contained in both the recipe and the user's pantry
            for food in sideFoods {
                for ing in rec.ingredientList {
                    if ing.contains(food) {
                        let key = keywords.index(forKey: food)
                        // Checks if the match is a common matching error, otherwise adds to score
                        if key == nil || !(keywords[key!].value.contains(where: {ing.contains($0)})){
                            numSides+=1
                            break
                        }
                    }
                }
            }
            // If there are more than 8 ingredients in the recipe, each ingredient past 8 makes the total
            // matches count for less
            if rec.ingredientList.count > 8 {
                numSides -= (rec.ingredientList.count - 8)/5  // Could modify numSides or numMains, doesn't matter
            }
            
            // If there were any matches,
            if numMains > 0 || numSides > 0 {
                let revs = Double(rec.reviews.replacingOccurrences(of: ",", with: "") ) // Remove commas for reviews in the thousands
                let reviewScore = min(revs ?? 0, 500) + max((revs ?? 0)-500,0)/10  // Numbers of reviews past 500 count 1/10
                let ratingScore = (Double(rec.rating) ?? 0.0 )/5.0                 // Adds score based on recipe rating
                let score = Double(numMains * 3 + numSides) * (reviewScore/2000 + ratingScore) // Tallies up score, this formula balances out the componenets
                // If the final score of the recipe is better than the current minScore, we add it to suggestions
                if score > minScore {
                    minScore = [score/2,minScore].max()!
                    let i = scores.firstIndex(where: {score > $0})
                    scores.insert(score, at: i!)           // also add the score to the scores list for easy sorting
                    suggestions.insert(rec, at: i!)
                }
            }
        }
        
        // We only want to output 25 suggestions to not overwhelm the app, here we truncate any suggestions
        // past 25 - they are in order of relevance, so we won't cut the best matches
        if suggestions.count > 25 {
            suggestions = Array(suggestions[0..<25])
        }
        print(scores)
    }
 
    // Creates a dictionairy that maps ingredients to terms commonly paired with them, which
    // do not represent the correct ingredient
    func createKeywordDict() -> [String: [String]] {
        var output = [String: [String]]()
        output["chicken"] = ["stock","broth","bouillon"]
        output["beef"] = ["stock","broth","bouillon"]
        output["corn"] = ["starch","meal","flour"]
        output["garlic"] = ["salt","powder"]
        output["ginger"] = ["ale"]
        output["onions"] = ["green","powder"]
        output["milk"] = ["powder","butter","evaporated","condensed"]
        return output
    }
}
