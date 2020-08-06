//
//  ViewController.swift
//  CompositionalEpisodes
//
//  Created by Ben Scheirman on 7/22/20.
//

import UIKit
import Combine

class ViewController: UIViewController {
    
    enum Section: Int, CaseIterable {
        case featured
        case recent
        case series
        case remaining
        
        var sectionHeader: String {
            switch self {
            case .featured: return "Featured"
            case .recent: return "Recent Episodes"
            case .series: return "Series"
            case .remaining: return "Past Episodes"
            }
        }
    }
    
    enum DataItem: Hashable {
        case episode(Episode)
        case series(Series)
    }
    
    enum SupplementaryElementKind {
        static let sectionHeader = "supplementary-section-header"
    }
    
    private var cancellables: Set<AnyCancellable> = []
    private var dataLoader = DataLoader()
    
    private var datasource: UICollectionViewDiffableDataSource<Section, DataItem>!
    private var collectionView: UICollectionView!
    private var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Episodes"
        
        loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.hidesWhenStopped = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingIndicator)
        
        configureCollectionView()
        fetchData()
    }
    
    private func configureCollectionView() {
        let layout = LayoutManager().createLayout()
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let featuredEpisodeCellRegistration = UICollectionView.CellRegistration<FeaturedEpisodeCell, DataItem> { cell, indexPath, dataItem in
            if case .episode(let episode) = dataItem {
                cell.titleLabel.text = episode.title
                cell.subtitleLabel.text = "#\(episode.episodeNumber)"
                cell.imageView.setImage(with: episode.mediumArtworkUrl)
            }
        }
        
        let episodeCellRegistration = UICollectionView.CellRegistration<EpisodeCell, DataItem> { cell, indexPath, dataItem in
            if case .episode(let episode) = dataItem {
                cell.titleLabel.text = episode.title
                cell.subtitleLabel.text = "#\(episode.episodeNumber)"
                cell.imageView.setImage(with: episode.mediumArtworkUrl)
            }
        }
        
        let seriesCellRegistration = UICollectionView.CellRegistration<SeriesCell, DataItem> { cell, indexPath, dataItem in
            if case .series(let series) = dataItem {
                cell.titleLabel.text = series.name
                cell.subtitleLabel.text = "\(series.installments.count) installments"
                cell.imageView.setImage(with: series.mediumArtworkURL)
            }
        }
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (collectionView, indexPath, model) -> UICollectionViewCell? in
            
            guard let sectionKind = Section(rawValue: indexPath.section) else {
                fatalError("Unhandled section: \(indexPath.section)")
            }
            
            switch sectionKind {
            case .featured:
                return collectionView.dequeueConfiguredReusableCell(using: featuredEpisodeCellRegistration, for: indexPath, item: model)
            
            case .recent:
                return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: model)
                
            case .series:
                return collectionView.dequeueConfiguredReusableCell(using: seriesCellRegistration, for: indexPath, item: model)
                
            case .remaining:
                return collectionView.dequeueConfiguredReusableCell(using: episodeCellRegistration, for: indexPath, item: model)
            }
        })
        
        let sectionHeaderRegistration = UICollectionView.SupplementaryRegistration<SectionHeader>(elementKind: SupplementaryElementKind.sectionHeader) { header, kind, indexPath in
            guard let sectionKind = Section(rawValue: indexPath.section) else {
                fatalError("Unhandled section: \(indexPath.section)")
            }
            header.label.text = sectionKind.sectionHeader
        }
        
        datasource.supplementaryViewProvider = { collectionView, kind, indexPath in
            switch kind {
            case SupplementaryElementKind.sectionHeader:
                return collectionView.dequeueConfiguredReusableSupplementary(using: sectionHeaderRegistration, for: indexPath)
                           
            default:
                return nil
            }
        }
    }
    
    private func fetchData() {
        dataLoader.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        dataLoader.dataChanged
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateSnapshot()
            }
            .store(in: &cancellables)
        
        dataLoader.fetchData()
    }
    
    private func updateSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, DataItem>()
        snapshot.appendSections(Section.allCases)
        
        struct Grouping {
            let episodes: [Episode]
            
            var featured: [Episode] {
                if episodes.count > 10 {
                    return Array(episodes.prefix(10))
                } else {
                    return []
                }
            }
            
            var recent: [Episode] {
                if episodes.count > 40 {
                    return Array(episodes.suffix(from: 10).prefix(30))
                } else {
                    return []
                }
            }
            
            var remaining: [Episode] {
                let usedCount = featured.count + recent.count
                if episodes.count > usedCount {
                    return Array(episodes.suffix(from: usedCount))
                } else {
                    return []
                }
            }
        }
        
        let grouping = Grouping(episodes: dataLoader.episodes)
        
        snapshot.appendItems(grouping.featured.map { DataItem.episode($0) }, toSection: .featured)
        snapshot.appendItems(grouping.recent.map { DataItem.episode($0) }, toSection: .recent)
        snapshot.appendItems(grouping.remaining.map { DataItem.episode($0) }, toSection: .remaining)
        snapshot.appendItems(dataLoader.series.map { DataItem.series($0) }, toSection: .series)
        
        datasource.apply(snapshot)
    }
}
