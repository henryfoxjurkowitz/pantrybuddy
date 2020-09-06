//
//  RecipePage.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 7/1/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

struct Ingred: Identifiable {
    var id = UUID()
    var ing: String
}

struct RecipePage: View {
    let recipe: Recipe
    @State var showSafari = false
    
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: SavedRecipe.entity(), sortDescriptors: []) var recipes: FetchedResults<SavedRecipe>
    
    var body: some View {
        let title = recipe.title
        var rating = recipe.rating
        if rating > "5.1" {rating = "0.0"} // means rating is really "none"
        let reviews = recipe.reviews
        let url = recipe.url
        let img = recipe.img
        let ingsToSave = recipe.ingredientList.joined(separator: "!") //chose a charcter that won't be in ingredient lists, is only used to store list as a string for core data
        var ingreds: [Ingred] = []
        for ing in recipe.ingredientList{
            ingreds.append(Ingred(ing: ing))
        }
        
        return ScrollView {
            VStack (alignment: .leading) {
                if !img.isEmpty {
                    ZStack {
                        ImgLoader(urlString: img)
                            .opacity(0.55)
                            .background(LinearGradient(gradient: Gradient(colors: [.white, .black]), startPoint: .top, endPoint: .bottom))
                        VStack {
                            Spacer()
                            HStack {
                                Text(title)
                                    .font(.title)
                                    .padding()
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }
                else {
                    Text(title)
                        .font(.title)
                        .padding([.leading,.top])
                        .foregroundColor(Color(red: 0.4, green: 0.69, blue: 0.52))
                    Spacer()
                }
                HStack {
                    Spacer()
                    Button(action: {
                        if !self.recipes.contains(where: {$0.name == title && $0.numReviews == reviews}) { // if this recipe is not saved
                            let newRec = SavedRecipe(context: self.moc)
                            newRec.id = UUID()
                            newRec.name = title
                            newRec.rating = rating
                            newRec.numReviews = reviews
                            newRec.url = url
                            newRec.img = img
                            newRec.ingreds = ingsToSave
                            newRec.priority = (self.recipes.map{$0.priority}.max() ?? 0)+1
                        }
                        else {
                            let rec = self.recipes.first(where: {$0.name == title && $0.numReviews == reviews})!
                            rec.priority = 0
                        }
                        try? self.moc.save()
                    }, label: {
                        if recipes.contains(where: {$0.name == title && $0.numReviews == reviews && $0.priority > 0}) { // if it is  saved
                            Image(systemName: "bookmark.fill")
                        }
                        else {
                            Image(systemName: "bookmark")
                        }
                    })
                    .buttonStyle(BorderlessButtonStyle())
                    .foregroundColor(Color.black)
                
                    Image(systemName: "link").padding(.horizontal,10).onTapGesture {
                        self.showSafari = true
                    }
                    .foregroundColor(Color(red: 0.4, green: 0.69, blue: 0.54))
                    .sheet(isPresented: $showSafari) {
                        SafariView(url:URL(string: url)!)
                    }
                    
                    Spacer()
                }
                .font(.system(size: 20))
                .padding(.top)
                .buttonStyle(BorderlessButtonStyle())
                
                HStack {
                    Stars(rating:rating)
                    Text("  \(reviews) Ratings")
                    Spacer()
                }
                .padding(.all)
                .font(.system(size: 18))
                
                Text("Ingredients: ")
                    .font(.title)
                    .padding([.leading,.bottom])
                ForEach (ingreds){ ing in
                    Text(ing.ing)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
        }
    }
}
