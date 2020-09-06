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
    @Published var suggestions: [Recipe] = []
    
    var keywords: [String: [String]] = [:]
    
    func updateSuggestions(searchText: String, foods: FetchedResults<Food>, recipes: [Recipe]) {
        keywords = createKeywordDict() // creates dictionary of common match errors
        var recs = recipes
        if !searchText.isEmpty {recs = recipes.filter({$0.title.localizedCaseInsensitiveContains(searchText)})} // if they put in search text, only include those recipes
        
        let pantryItems = foods.filter({$0.priority > 0}) // foods that are in the pantry
        let sideFoods: [String] = pantryItems.filter({!$0.mainFood}).map({$0.name?.lowercased() ?? ""}) // maps names of non-main foods
        let mainFoods: [String] = pantryItems.filter({$0.mainFood}).map({$0.name?.lowercased() ?? ""})  // maps names of main foods

        var scores:[Double] = [0.0] // list to reference to sort recipes
        suggestions = []
        var minScore = 0.0
        
        for ind in 0..<recs.count {
            let rec = recs[ind]
            var numMains = 0
            var numSides = 0
            for food in mainFoods {
                for ing in rec.ingredientList {
                    if ing.contains(food) {
                        let key = keywords.index(forKey: food)
                        if key == nil || !(keywords[key!].value.contains(where: {ing.contains($0)})){
                            numMains+=1
                            break
                        }
                    }
                }
            }
            for food in sideFoods {
                for ing in rec.ingredientList {
                    if ing.contains(food) {
                        let key = keywords.index(forKey: food)
                        if key == nil || !(keywords[key!].value.contains(where: {ing.contains($0)})){
                            numSides+=1
                            break
                        }
                    }
                }
            }
            if rec.ingredientList.count > 8 {
                numSides -= (rec.ingredientList.count - 8)/3 // counts for less if too many imgreds
            }
            if numMains > 0 || numSides > 0 { // if there were any matches
                let revs = Double(rec.reviews.replacingOccurrences(of: ",", with: "") ) // remove commas for thousands
                let reviewScore = min(revs ?? 0, 500) + max((revs ?? 0)-500,0)/10
                let ratingScore = (Double(rec.rating) ?? 0.0 )/5.0
                let score = Double(numMains * 3 + numSides) * (reviewScore/2000 + ratingScore)
                if score > minScore {
                    minScore = [score/2,minScore].max()!
                    let i = scores.firstIndex(where: {score > $0})
                    scores.insert(score, at: i!)
                    suggestions.insert(rec, at: i!)
                }
            }
        }
        if suggestions.count > 25 {
            suggestions = Array(suggestions[0..<25])
        }
        print(scores)
            
            
            /*
            
            if matchIngreds(rec.ingredientList, sideFoods + mainFoods, minScore)
            {
                let revs = rec.reviews.replacingOccurrences(of: ",", with: "") // remove commas for thousands
                let score = getScore(rec.ingredientList, Double(rec.rating) ?? 0.0, Double(revs) ?? 500.0, sideFoods, mainFoods)
                if score > minScore {
                    minScore = [[score/2,minScore].max()!,350].min()!
                    for i in 0...scores.count {
                        if score >= scores[i] {
                            scores.insert(score, at: i)
                            suggestions.insert(rec, at: i)
                            break
                        }
                    }
                }
            }
        }
        print(scores)
        suggestions = Array(suggestions[0...25])
 */

    }
 
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
    
    /*
    func matchIngreds (_ ingreds: [String],_ pantry: [String],_ minScore: Double) -> Bool {
        if minScore < 200 {
            for item in pantry {
                if ingreds.contains(where: { $0.contains(item) }) { return true}
            }
            return false
        }
        else {
            var foundOne = false
            for item in pantry {
                if ingreds.contains(where: { $0.contains(item) }) {
                    if foundOne {return true}
                    else {foundOne = true}
                }
            }
            return false
        }
    }
    
    func getScore (_ ingreds: [String],_ rating: Double,_ reviews: Double,_ sideList: [String],_ mainList: [String]) -> Double {
        var mains = mainList
        var sides = sideList
        var howGood = 0.01 * ([reviews, 500.0].min() ?? 0.0) + 2 * rating
        if reviews > 500.0 {
            howGood += (reviews - 500.0) * 0.001
        }
        var howHandy = 0
        if sideList.isEmpty && mainList.isEmpty { howHandy = 12 }
        var hadMain = false
        let divider = ([ingreds.count, 8]).max() ?? 8 // only care about too many ingredients if recipe has more than 7
        ingreds.forEach { ingredient in
            mains.forEach { food in
                if ingredient.contains(food) {
                    if (food.contains("chicken") || food.contains("beef")) && !food.contains("broth") && !food.contains("stock") && !food.contains("bouillon") && (ingredient.contains("broth") || ingredient.contains("stock") || ingredient.contains("bouillon")) {
                        if hadMain {howHandy -= 50/ingreds.count}
                        else {howHandy -= 150/divider}
                    }
                    if hadMain { howHandy += 50/divider } // checks if recipe already has a mainfood
                    else {
                        hadMain = true
                        howHandy += 150/divider
                    }
                    mains.remove(at: mains.firstIndex(of: food)!)
                }
            }
            sides.forEach { food in
                if ingredient.contains(food) {
                    if food == "corn" && (ingredient.contains("starch") || !ingredient.contains("meal")) {
                        howHandy -= 50/divider
                    }
                    if food == "garlic" && ingredient.contains("salt") {howHandy -= 50/divider}
                    if food == "ginger" && ingredient.contains("ale") {howHandy -= 50/divider}
                    if food == "onion" && ingredient.contains("green") {howHandy -= 50/divider}
                    if food == "milk" && (ingredient.contains("butter") || ingredient.contains("evaporated") || ingredient.contains("condensed")) {howHandy -= 50/divider}
                    howHandy += 50/divider
                    sides.remove(at: sides.firstIndex(of: food)!)
                }
            }
        }
        return howGood * Double(howHandy)
        
    }
 */
}
