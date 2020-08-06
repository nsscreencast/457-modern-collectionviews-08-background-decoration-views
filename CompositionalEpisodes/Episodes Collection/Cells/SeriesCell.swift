//
//  SeriesCell.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/23/20.
//

import UIKit

class SeriesCell: UICollectionViewCell {
    static let reuseIdentifier = "SeriesCell"
    
    let titleLabel = UILabel()
    let subtitleLabel = UILabel()
    let imageView = RemoteImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundView = UIView()
        backgroundView?.backgroundColor = .tertiarySystemBackground
        backgroundView?.layer.cornerRadius = 8
        backgroundView?.layer.masksToBounds = true
        
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        
        titleLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 3
        
        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        
        let separator = UIView()
        separator.backgroundColor = .quaternaryLabel
        
        let spacerView = UIView()
        
        let stack = UIStackView(arrangedSubviews: [
            separator, titleLabel, subtitleLabel, spacerView, imageView
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        stack.setCustomSpacing(10, after: separator)
        stack.setCustomSpacing(10, after: subtitleLabel)
    }
}
