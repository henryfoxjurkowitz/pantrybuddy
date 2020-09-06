//
//  CreateFoodView.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/19/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI


struct CreateFoodView: View {
    let menuSwitch: CreateFoodMenu
    @State var text: String
    @State var isMain = false

    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Food.entity(), sortDescriptors: []) var foods: FetchedResults<Food>
    
    var body: some View {
        HStack{
            VStack (alignment: .leading) {
                ZStack {
                    TextField(text, text: $text)
                        .padding(.horizontal)
                        .padding(.vertical,10)
                        .background(Color(red: 0.9, green: 0.9, blue: 0.9))
                        .cornerRadius(10)
                    VStack { // this is just to fix swiftui's lack of a method for rounded corners on only some corners
                        Spacer()
                            .frame(height:35)
                        Rectangle()
                            .fill(Color(red: 0.9, green: 0.9, blue: 0.9))
                            .frame(height: 10)
                    }
                }
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
                    Button ("Cancel") {
                        self.menuSwitch.tog(false)
                    }
                    .padding(10)
                    
                    Spacer()
                    Button ("Add") {
                        let food = Food(context: self.moc)
                        if !self.text.isEmpty {
                            food.name = self.text
                            food.id = UUID()
                            food.isCustom = true
                            food.mainFood = self.isMain
                            food.priority = (self.foods.map{$0.priority}.max() ?? 0)+1 // priority 1 or one more than the greatest current priority value
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
