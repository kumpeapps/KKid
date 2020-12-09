//
//  ViewController.swift
//  KMovies
//
//  Created by Justin Kumpe on 11/25/20.
//

import UIKit
import Kingfisher
import KumpeHelpers
import JKRefresher
import ContentRestrictionsKit

class MovieSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

// MARK: searchBars
    @IBOutlet weak var searchBar: UISearchBar!

// MARK: collectionViews
    @IBOutlet weak var collectionView: UICollectionView!

// MARK: parameters
    var movies: [TMDb_Movie] = []
    var currentPage: Int = 0
    var totalPages: Int = 0
    let movieCache = ImageCache(name: "KMovies")

// MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        #if targetEnvironment(simulator)
        UserDefaults.standard.set(400, forKey: "com.apple.content-rating.MovieRating")
        #endif
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .onDrag
        collectionView.am.addInfiniteScrolling {
            self.performFetchMore {
                self.collectionView.am.infiniteScrollingView?.stopRefreshing()
            }
        }
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        movieCache.cleanExpiredMemoryCache()
    }

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if targetEnvironment(simulator)
            searchBar.text = "Stargate"
            performFetchMore { }
        #endif
    }

// MARK: didRecieveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        movieCache.clearMemoryCache()
    }

// MARK: searchBar-textDidChange
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        TMDb_Client.searchMovies(query: searchBar.text!, page: 1) { (_, response) in
            self.movies = []
            self.currentPage = 0
            self.totalPages = 0
            if let response = response {
                self.movies = response.results
                self.currentPage = response.page
                self.totalPages = response.totalPages
                self.collectionView.reloadData()
            }
        }
    }

// MARK: performFetchMore
    func performFetchMore(_ completionHandler: (() -> Void)?) {
        let page = self.currentPage + 1
        TMDb_Client.searchMovies(query: searchBar.text!, page: page) { (_, response) in
            if let response = response {

                // create new index paths
                let movieCount = self.movies.count
                let (start, end) = (movieCount, response.results.count + movieCount)
                let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }

                // update data source
                self.movies.append(contentsOf: response.results)
                self.currentPage = response.page
                self.totalPages = response.totalPages

                // update collection view
                self.collectionView?.performBatchUpdates({ () -> Void in
                    self.collectionView?.insertItems(at: indexPaths)
                }, completion: { (_) -> Void in
                    completionHandler?()
                })
            }
        }
    }

// MARK: prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! MovieDetailViewController
        if let indexPath = collectionView.indexPathsForSelectedItems {
            viewController.selectedMovie = movies[indexPath[0].row]
        }
    }

}

// MARK: - Collection View Functions
extension MovieSearchViewController {

    // MARK: Set Number of Items
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return movies.count
        }

    // MARK: Build Items
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
            let movie = movies[indexPath.row]
            if let imageSuffix = movie.posterPath {
                let imagePath = URL(string: "\(TMDb_Constants.PosterUrl.w185.baseUrl)\(imageSuffix)")
                let processor = RoundCornerImageProcessor(cornerRadius: 20)
                cell.imageView.kf.setImage(
                    with: imagePath,
                    placeholder: UIImage(named: "placeholder_w185"),
                    options: [
                        .processor(processor),
                        .transition(.fade(1)),
                        .cacheOriginalImage,
                        .cacheSerializer(FormatIndicatedCacheSerializer.png),
                        .targetCache(movieCache)
                    ])
            } else {
                cell.imageView.image = UIImage(named: "placeholder_w185")
            }
            if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: movie.movieRating ?? "nr") {
                cell.imageView.image = UIImage(named: "placeholder_w185")
            }
            return cell
        }

    // MARK: Did Select Item
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: movies[indexPath.row].movieRating ?? "nr") {
                ShowAlert.banner(title: "Access Restricted", message: "This movie is rated \(movies[indexPath.row].movieRating ?? "nr") which is above the restriction level set on your device.")
            } else {
                performSegue(withIdentifier: "segueMovieDetails", sender: self)
            }
        }

}
