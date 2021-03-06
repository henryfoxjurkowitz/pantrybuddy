//
//  Stars.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 7/15/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI

// View that displays the stars for a recipe given the recipes numerical rating
struct Stars: View {
    var rating: String
    
    var body: some View {
        HStack {
            // Horizontally adds a filled star if it has that star, otherwise empty
            if (rating == "0.0") {Image(systemName: "star")}
            else {Image(systemName: "star.fill")}
            if (rating >= "1.75") {Image(systemName: "star.fill") }
            else if (rating >= "1.25") {Image(systemName: "star.lefthalf.fill") }
            else {Image(systemName: "star")}
            if (rating >= "2.75") {Image(systemName: "star.fill") }
            else if (rating >= "2.25") {Image(systemName: "star.lefthalf.fill") }
            else {Image(systemName: "star")}
            if (rating >= "3.75") {Image(systemName: "star.fill") }
            else if (rating >= "3.25") {Image(systemName: "star.lefthalf.fill") }
            else {Image(systemName: "star")}
            if (rating > "4.75") {Image(systemName: "star.fill") }
            else if (rating > "4.25")  {Image(systemName: "star.lefthalf.fill") }
            else {Image(systemName: "star")}
        }
    }
}

struct Stars_Previews: PreviewProvider {
    static var previews: some View {
        Stars(rating: "5")
    }
}
