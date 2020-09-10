//
//  Bundle-Decodable.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/10/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import Foundation


// extension to decode the JSON file we read in
extension Bundle {
    func decode (_ file: String) -> [Recipe] {
        // Get the file
        guard let url = self.url(forResource: file, withExtension: nil) else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        // Load the file
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load \(file) in bundle.")
        }
        // Decode the file
        let decoder = JSONDecoder()
        guard let loaded = try? decoder.decode([Recipe].self, from: data) else {
            fatalError("Failed to decode \(file) in bundle.")
        }
        return loaded
    }
}
