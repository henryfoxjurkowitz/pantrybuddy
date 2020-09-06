//
//  SavedTab.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/26/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

struct SavedTab: View {
    var body: some View {
        NavigationView{
            VStack(spacing: 30) {
                NavigationLink(destination: SavedRecipes()) {
                    HStack {
                        Image(systemName: "bookmark.fill").padding(.trailing)
                        Text("Saved Recipes")
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding([.horizontal,.top])
                }
                NavigationLink(destination: CustomFoods()) {
                    HStack {
                        Image(systemName: "cart").padding(.trailing)
                        Text("Custom Foods")
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                }
                Spacer()
                
                VStack {
                    Image(systemName: "bookmark")
                        .font(.system(size: 80))
                    Text("Use this tab to view recipes")
                        .padding(.top)
                    Text("and foods that you've saved!")
                }
                .foregroundColor(.gray)
                .padding(.bottom,130)
                Spacer()
            }
            .navigationBarTitle("My Account")
            .foregroundColor(.gray)
            .background(Color(red: 0.52, green: 0.93, blue: 0.7)
                    .edgesIgnoringSafeArea(.all))
            
        }
        .accentColor(.black)
    }
}

struct SavedTab_Previews: PreviewProvider {
    static var previews: some View {
        SavedTab()
    }
}
