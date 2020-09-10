//
//  ImgLoader.swift
//  Pantry Pal (core data)
//
//  Created by Henry on 7/1/20.
//  Copyright © 2020 Henry Fox-Jurkowitz. All rights reserved.
//

import SwiftUI
import Combine

// Used to load in images for RecipePage views
class ImageLoader: ObservableObject {
    @Published var image: UIImage?              // The UIImage that the class will publish
    private let url: URL                        // The url of the image
    private var cancellable: AnyCancellable?    // Allows the image loading to cancel when view dissapears

    init(url: URL) {
        self.url = url
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    // Loads the image
    func load() {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
        .map { UIImage(data: $0.data) }
        .replaceError(with: nil)
        .receive(on: DispatchQueue.main)
        .assign(to: \.image, on: self)
    }

    // Function to cancel the image loading
    func cancel() {
        cancellable?.cancel()
    }
}

// Asynchronously loads image
struct AsyncImage<Placeholder: View>: View {
    @ObservedObject private var loader: ImageLoader  // Pass in the ImageLoader
    private let placeholder: Placeholder?            // Placeholder for the image
    
    init(url: URL, placeholder: Placeholder? = nil) {
        loader = ImageLoader(url: url)
        self.placeholder = placeholder
    }

    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: some View {
        Group {
            // Sets the image if it successfully loads, otherwise sets placeholder
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable()
            } else {
                placeholder
            }
        }

    }
}

// The struct to actually display the image
struct ImgLoader: View {
    let urlString: String
    var body: some View {
        let url = URL(string: urlString)!

        return AsyncImage(
            url: url,
            placeholder: Text(" ")
        ).aspectRatio(contentMode: .fit) // lets the image scale to fit

    }
}

struct ImgLoader_Previews: PreviewProvider {
    static var previews: some View {
        ImgLoader(urlString: "https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fimages.media-allrecipes.com%2Fuserphotos%2F3301138.jpg")
    }
}
