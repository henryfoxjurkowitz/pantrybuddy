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

struct SearchBar: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String

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

    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }

    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
            //textField.font = myFont
            //textField.textColor = UIColor(red: 255/255, green: 74/255, blue: 103/255, alpha: 1)
            
            let backgroundView = textField.subviews.first
            if #available(iOS 11.0, *) { // If `searchController` is in `navigationItem`
                backgroundView?.backgroundColor = UIColor.white.withAlphaComponent(0.3) //Or any transparent color that matches with the `navigationBar color`
                backgroundView?.subviews.forEach({ $0.removeFromSuperview() }) // Fixes an UI bug when searchBar appears or hides when scrolling
            }
            backgroundView?.layer.cornerRadius = 10.5
            backgroundView?.layer.masksToBounds = true
            
        }
        //searchBar.autocapitalizationType = .none
        return searchBar
    }

    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

