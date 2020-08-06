//
//  SeriesBackgroundDecoration.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/23/20.
//

import UIKit

class SeriesBackgroundDecoration: UICollectionReusableView {
    static let reuseIdentifier = "series-background-decoration"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.clear(rect)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: colorSpace, colors: [
            UIColor.secondarySystemBackground.cgColor,
            UIColor.clear.cgColor
        ] as CFArray, locations: nil)!
        
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: bounds.minY), end: CGPoint(x: 0, y: bounds.maxY), options: [])
    }
}
