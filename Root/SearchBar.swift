//
//  SearchBar.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 6/24/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit


// creating a custom search bar using UIKit
struct SearchBar: UIViewRepresentable {
    @Binding var text: String  // the variable storing the inputted text
    var placeholder: String    // the String that appears initially in the search bar

    // Coordinator to update text once the user has clicked on and typed into the search bar
    class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            UIApplication.shared.endEditing()
        }
        
        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
            return true
        }
    }

    // creates the coordinator
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    // makes the SearchBar
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)  // start with a UISearchBar
        searchBar.delegate = context.coordinator   // sets delegate to the coordinator we created
        searchBar.placeholder = placeholder        // sets the placeholder to parameter
        searchBar.searchBarStyle = .minimal
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField { // initializing the textfield
            textField.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            
            let backgroundView = textField.subviews.first
            if #available(iOS 11.0, *) { // If `searchController` is in `navigationItem`
                backgroundView?.backgroundColor = UIColor.white.withAlphaComponent(0.3)  // sets the background color of search bar
                backgroundView?.subviews.forEach({ $0.removeFromSuperview() })           // Fixes an UI bug when searchBar appears or hides when scrolling
            }
            backgroundView?.layer.cornerRadius = 10.5       // sets corner radius of search bar
            backgroundView?.layer.masksToBounds = true      // clips content to the corner radius we set
            
        }
        return searchBar
    }
    
    // updates the text in the search bar
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
}

// removes the cursor in search bar when endEditing() is called
extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

