//
//  CustomFoods.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 7/15/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

// Displays all custom foods user has created, allows for deleting
struct CustomFoods: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food> // Gets list of Foods from core data
    
    var body: some View {
        List {
            // Lists each custom food that they created
            ForEach (foods.filter({$0.isCustom}), id: \.id) { food in
                HStack {
                    Text(food.name ?? "Unknown")
                    Spacer()
                    Image(systemName: "x.circle")
                        .onTapGesture {
                        self.moc.delete(food)
                        try? self.moc.save()
                    }
                }
            }
        }.navigationBarTitle("Custom Foods")
    }
}

struct CustomFoods_Previews: PreviewProvider {
    static var previews: some View {
        CustomFoods()
    }
}
