//
//  Loader.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/24/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

class LoadFoodNames:ObservableObject {
    @Published var data: String = ""
    init() {
        self.load(file: "foods")
    }
    func load(file: String) {
        if let filepath = Bundle.main.path(forResource: file, ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                DispatchQueue.main.async {
                    self.data = contents
                }
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            print("File not found")
        }
    }
}

struct LoaderView: View {
    @ObservedObject var loader = LoadFoodNames()
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
    
        
    var body: some View {
        addTheFoods()
        return Text("Adding Foods...")
            .padding()
            .background(Color.white)
            .cornerRadius(15)
    }
    
    func addTheFoods () {
        let text = loader.data
        let array = text.components(separatedBy: .newlines)
        for item in array {
            let foodWithMain = item.components(separatedBy:",") // splits each item into food name and main label
            if foodWithMain.count > 0 {
                let food = foodWithMain[0]
                var found = false
                for existingFood in foods { // checks to make sure food isn't already in core data
                    if food == existingFood.name ?? "Unknown" {
                        found = true
                        break
                    }
                }
                if !found { // if food isn't in core data, adds it
                    let newFood = Food(context: self.moc)
                    newFood.name = food
                    newFood.id = UUID()
                    newFood.isCustom = false
                    newFood.priority = 0
                    newFood.mainFood = foodWithMain.count > 1 // it's a main food if the text had a comma separating the food name and the main label
                    try? self.moc.save()
                }
            }
        }
    }
}


