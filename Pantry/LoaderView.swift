//
//  Loader.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/24/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

// Loads the foods from foods.txt into app
class LoadFoodNames:ObservableObject {
    @Published var data: String = ""  // String representing the String form of the txt file
    init() {
        self.load(file: "foods")
    }
    
    // Loads the contents of the txt into our var data
    func load(file: String) {
        if let filepath = Bundle.main.path(forResource: file, ofType: "txt") { // If we can find the file
            do {
                let contents = try String(contentsOfFile: filepath) // Get the contents of the file
                DispatchQueue.main.async {
                    self.data = contents    // Set our data to the contents
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }
}

// View that loads in the foods.txt file
struct LoaderView: View {
    @ObservedObject var loader = LoadFoodNames() // ObservedObject that gets the contents from foods.txt as a String
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food> // Gets a reference to the list of Foods in core data
    
        
    var body: some View {
        addTheFoods()  // Load foods into core data
        return Text("Adding Foods...") // The visible view is only this text
            .padding()
            .background(Color.white)
            .cornerRadius(15)
    }
    
    // Adds the foods to Food list in core data
    func addTheFoods () {
        let text = loader.data
        let array = text.components(separatedBy: .newlines) // Each element of array is the food with or without a label indicating a main food
        for item in array {
            let foodWithMain = item.components(separatedBy:",") // Splits each item into food name and main label
            if foodWithMain.count > 0 {
                let food = foodWithMain[0]
                var found = false
                for existingFood in foods { // Checks to make sure food isn't already in core data
                    if food == existingFood.name ?? "Unknown" {
                        found = true
                        break
                    }
                }
                if !found {   // If food isn't in core data yet, add it
                    
                    // Initialize default attributes of Food objects
                    let newFood = Food(context: self.moc)
                    newFood.name = food
                    newFood.id = UUID()
                    newFood.isCustom = false
                    newFood.priority = 0
                    newFood.mainFood = foodWithMain.count > 1 // it's a main food if the array of it's components had multiple elements
                    try? self.moc.save()
                }
            }
        }
    }
}


