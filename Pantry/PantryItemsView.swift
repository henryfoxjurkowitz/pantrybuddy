//
//  PantryItemsView.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/24/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

struct PantryItemsView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
    
    var body: some View {
        VStack {
            ForEach(foods.filter({$0.priority > 0}).sorted(by: {$0.priority < $1.priority}), id: \.id) { food in
                HStack {
                    Text(food.name ?? "Unknown")
                    Spacer()
                    Image(systemName: "minus.circle").onTapGesture {
                        food.priority = 0 // deletes the food from pantry
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
            
            if foods.filter({$0.priority > 0}).isEmpty { // no foods are in the paantry
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
