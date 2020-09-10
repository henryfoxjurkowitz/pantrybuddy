//
//  CreateFoodView.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/19/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI


struct CreateFoodView: View {
    let menuSwitch: CreateFoodMenu // Pass the object controlling this menu so that we can close it from within the menu
    @State var text: String        // The text for the food that the user is creating
    @State var isMain = false      // Stores whether this food is a main food

    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food> // Gets the list of Foods from core data
    
    var body: some View {
        HStack{
            VStack (alignment: .leading) {
                ZStack {
                    // Text field bound to the text variable
                    TextField(text, text: $text)
                        .padding(.horizontal)
                        .padding(.vertical,10)
                        .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                        .cornerRadius(10)
                    // this VStack is to fix SwiftUI's lack of a method for rounded corners on only some corners
                    VStack {
                        Spacer()
                            .frame(height:35)
                        Rectangle()
                            .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                            .frame(height: 10)
                    }
                }
                
                // Buttons to toggle whether the ingredient they are creating is an essential ingredient
                HStack {
                    Button (action: {
                        self.isMain = true
                    }) {
                        if isMain { Image(systemName: "circle.fill") }
                        else {Image(systemName: "circle")}
                    }.padding(.horizontal,20)
                    Text("Main Ingredient")
                }
                HStack {
                    Button (action: {
                        self.isMain = false
                    }) {
                        if isMain { Image(systemName: "circle") }
                        else { Image(systemName: "circle.fill") }
                    }
                    .padding(.horizontal,20)
                    
                    Text("Non-Essential")
                }
                
                HStack {
                    Spacer()
                    
                    // Button to cancel and close the create food menu
                    Button ("Cancel") {
                        self.menuSwitch.tog(false)
                    }
                    .padding(10)
                    
                    Spacer()
                    
                    // Button to add the created food to core data for future use
                    Button ("Add") {
                        let food = Food(context: self.moc)
                        if !self.text.isEmpty {
                            food.name = self.text
                            food.id = UUID()
                            food.isCustom = true
                            food.mainFood = self.isMain
                            // set priority to 1, or to 1 more than the greatest priority existing in Foods so far
                            food.priority = (self.foods.map{$0.priority}.max() ?? 0)+1
                        }
                        self.menuSwitch.tog(false)
                    }
                    .padding(10)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: 200)
        }
        .background(Color.white
        .cornerRadius(10)
        )
    }
}

struct CreateFoodView_Previews: PreviewProvider {
    static var previews: some View {
        CreateFoodView(menuSwitch: CreateFoodMenu(),text: "HI")
    }
}
