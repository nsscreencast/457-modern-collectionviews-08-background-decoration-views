//
//  RemoteImageView.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/22/20.
//

import UIKit
import Combine

class RemoteImageView: UIImageView {
    var imageCancellable: AnyCancellable?
    
    func setImage(with url: URL) {
        cancelImageRequest()
        image = nil
        
        imageCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .map { UIImage.init(data: $0) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    func cancelImageRequest() {
        imageCancellable = nil
    }
}
