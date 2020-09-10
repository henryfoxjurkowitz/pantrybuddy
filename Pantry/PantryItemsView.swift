//
//  PantryItemsView.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/24/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI


// View that displays all items that are in the user's pantry
struct PantryItemsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food> // Gets list of Foods from core data
    
    var body: some View {
        VStack {
            ForEach(foods.filter({$0.priority > 0}).sorted(by: {$0.priority < $1.priority}), id: \.id) { food in
                HStack {
                    Text(food.name ?? "Unknown")
                    Spacer()
                    Image(systemName: "minus.circle").onTapGesture { // Delete the food from pantry by setting priority to 0
                        food.priority = 0
                        try? self.moc.save()
                    }
                }
                .padding()
            }
            .background(Color.white)
            .cornerRadius(10)
            .padding(.top,-5)
            .padding(.horizontal,5)
            .shadow(radius: 5)
            
            // Display placeholder image and text if no foods are in the pantry
            if foods.filter({$0.priority > 0}).isEmpty {
                VStack {
                    Image(systemName: "cart")
                        .font(.system(size: 80))
                    Text("There's nothing in your pantry!")
                        .padding(.top)
                    Text("Search for foods to add!")
                }
                .padding(.top, 100)
                .foregroundColor(.gray)
            }
        }
    }
}

struct PantryItemsView_Previews: PreviewProvider {
    static var previews: some View {
        PantryItemsView()
    }
}
