//
//  RemoteImageView.swift
//  TGHProfile
//
//  Created by T0366-ADE-MB-1 on 05/01/2023.
//

import SwiftUI

struct RemoteImageView<Placeholder: View, ConfiguredImage: View>: View {
    var urlString: String
    private let placeholder: () -> Placeholder
    private let image: (Image) -> ConfiguredImage

    @ObservedObject var imageLoader: ImageLoaderService
    @State var imageData: UIImage?

    init(
        urlString: String,
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder image: @escaping (Image) -> ConfiguredImage
    ) {
        self.urlString = urlString
        self.placeholder = placeholder
        self.image = image
        self.imageLoader = ImageLoaderService(url: urlString)
    }

    @ViewBuilder private var imageContent: some View {
        if let data = imageData {
            image(Image(uiImage: data))
        } else {
            placeholder()
        }
    }

    var body: some View {
        imageContent
            .onReceive(imageLoader.$image) { imageData in
                self.imageData = imageData
            }
    }
}

class ImageLoaderService: ObservableObject {
    @Published var image = UIImage()

    convenience init(url: String) {
        self.init()
        loadImage(for: url)
    }

    func loadImage(for urlString: String) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let data = data else { return }
                DispatchQueue.main.async {
                    self.image = UIImage(data: data) ?? UIImage()
                }
            }
            task.resume()
        }else{
            self.image = UIImage()
        }
       
        
    }
}
