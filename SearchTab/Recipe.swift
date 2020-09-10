//
//  Recipe.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/10/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import Foundation

// Custom struct of a Recipe to display, modify, and search for recipes
struct Recipe: Codable, Identifiable {
    let title: String
    let rating: String
    let reviews: String
    let ingredientList: [String]
    let url: String
    let id: String
    let img: String
}
