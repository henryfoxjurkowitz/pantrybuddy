//
//  RecipeCard.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/15/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI
import SafariServices

struct RecipeCard: View {
    let recipe: Recipe
    let showDivider: Bool // adds a black line to separate cards in search tab
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
        let ings = recipe.ingredientList.joined(separator: "!") //chose a charcter that won't be in ingredient lists, is only used to store list as a string for core data
        
        return VStack {
            HStack {
                //title
                if (title.count > 31) {
                    Text(title.prefix(31) + "...") // cut off title if it's too long to fit
                        .font(.system(size: 15))
                } else {
                    Text(title)
                    .font(.system(size: 15))
                }
                Spacer()
                
                //save button
                Button(action: {
                    if !self.recipes.contains(where: {$0.name == title && $0.numReviews == reviews}) { // if this recipe is not saved
                        let newRec = SavedRecipe(context: self.moc)
                        newRec.id = UUID()
                        newRec.name = title
                        newRec.rating = rating
                        newRec.numReviews = reviews
                        newRec.url = url
                        newRec.img = img
                        newRec.ingreds = ings
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
                
                Image(systemName: "link").padding(.horizontal,10).onTapGesture {
                    self.showSafari = true
                }
                .foregroundColor(Color(red: 0.4, green: 0.69, blue: 0.54))
                .sheet(isPresented: $showSafari) {
                    SafariView(url:URL(string: url)!)
                }
            }
            
            HStack {
                Stars(rating: rating)
                Spacer()
                Text("\(reviews) Ratings")
                    .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
            }
            .padding(5)
            .font(.system(size: 10))
            .foregroundColor(Color(red: 0.4, green: 0.69, blue: 0.54))
            
            if showDivider {
                Divider().background(Color.black)
            }
        }.foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3)).padding(.vertical,3)
    }
}

struct SafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}
