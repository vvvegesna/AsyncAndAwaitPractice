//
//  ContentView.swift
//  AsyncAndAwaitPractice
//
//  Created by Vegesna, Vijay Varma on 7/16/22.
//

import SwiftUI

class AsyncAndAwaitDataManager {
    
    private let url = URL(string: "https://picsum.photos/200")!
    
    private func handleResponse(_ data: Data?, _ response: URLResponse?) -> UIImage? {
        guard let response = response as? HTTPURLResponse,
              response.statusCode >= 200 && response.statusCode < 300,
              let data = data,
              let uiImage = UIImage(data: data) else {
            return nil
        }
        return uiImage
    }
    
    enum ImageLoadingError: Error {
        case failToConvert
    }
    
    func fetchWithCompletion(_ completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                completionHandler(nil, error)
            }
            guard let uiImage = self?.handleResponse(data, response) else {
                completionHandler(nil, ImageLoadingError.failToConvert)
                return
            }
            completionHandler(uiImage, nil)
        }.resume()
    }
}

class AsyncAndAwaitViewModel: ObservableObject {
    
    @Published var image: Image?
    @Published var wedError: String?
    
    let dataManager = AsyncAndAwaitDataManager()
    
    func fetchImage() {
//        if let uiImage = UIImage(systemName: "heart.fill") {
//            self.image = Image(uiImage: uiImage)
//        }
        dataManager.fetchWithCompletion { [weak self] image, error in
            DispatchQueue.main.async {
                if let image = image {
                    self?.image = Image(uiImage: image)
                } else {
                    self?.wedError = error?.localizedDescription
                }
            }
        }
    }
    
    
}

struct ContentView: View {
    @StateObject private var vm = AsyncAndAwaitViewModel()
    
    var body: some View {
        ZStack {
            vm.image?
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250)
            if let error = vm.wedError {
                Text(error)
            }
        }
        .onAppear {
            vm.fetchImage()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
