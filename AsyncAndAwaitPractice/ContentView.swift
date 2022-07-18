//
//  ContentView.swift
//  AsyncAndAwaitPractice
//
//  Created by Vegesna, Vijay Varma on 7/16/22.
//

import SwiftUI
import Combine

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
    /*
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
    } */
    
    func fetchWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
        
    }
}

class AsyncAndAwaitViewModel: ObservableObject {
    
    @Published var image: Image?
    @Published var wedError: String?
    
    let dataManager = AsyncAndAwaitDataManager()
    var cancellables = Set<AnyCancellable>()
    func fetchImage() {
        //        if let uiImage = UIImage(systemName: "heart.fill") {
        //            self.image = Image(uiImage: uiImage)
        //        }
        //        dataManager.fetchWithCompletion { [weak self] image, error in
        //            DispatchQueue.main.async {
        //                if let image = image {
        //                    self?.image = Image(uiImage: image)
        //                } else {
        //                    self?.wedError = error?.localizedDescription
        //                }
        //            }
        //        }
        dataManager.fetchWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in 
            } receiveValue: { [weak self] uiImage in
                if let image = uiImage {
                    self?.image = Image(uiImage: image)
                }
            }
            .store(in: &cancellables)
        
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
