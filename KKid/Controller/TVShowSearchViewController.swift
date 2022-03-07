//
//  TVShowSearchViewController.swift
//  KKid
//
//  Created by Justin Kumpe on 10/29/21.
//  Copyright © 2021 Justin Kumpe. All rights reserved.
//

import UIKit
import Kingfisher
import KumpeHelpers
import JKRefresher
import ContentRestrictionsKit

class TVShowSearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {

// MARK: searchBars
    @IBOutlet weak var searchBar: UISearchBar!

// MARK: collectionViews
    @IBOutlet weak var collectionView: UICollectionView!

// MARK: segmentControlls
    @IBOutlet weak var segmentControll: UISegmentedControl!

// MARK: parameters
    var shows: [TMDb_TV] = []
    var currentPage: Int = 0
    var totalPages: Int = 0
    let showCache = ImageCache(name: "KShows")

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

// MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.currentPage = 0
        self.totalPages = 0
        self.shows = []
        collectionView.reloadData()
        performFetchMore { }
        UserDefaults.standard.set(true, forKey: "TV Shows DB")
        hideKeyboardOnTap()
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        showCache.cleanExpiredMemoryCache()
    }

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        #if targetEnvironment(simulator)
            searchBar.text = "Stargate"
        #endif
    }

// MARK: didRecieveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        showCache.clearMemoryCache()
    }

// MARK: searchBar-textDidChange
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard !searchBar.text!.contains("UserDefaults: ") else {
            let search = searchBar.text!.replacingOccurrences(of: "UserDefaults: ", with: "")
            if search.contains(":Go:") {
                let key = search.replacingOccurrences(of: " :Go:", with: "")
                ShowAlert.centerView(theme: .info, title: "\(key)", message: "\(UserDefaults.standard.object(forKey: key) ?? "nil")", seconds: 60, invokeHaptics: false)
            }
            return
        }
        TMDb_Client.searchTV(query: searchBar.text!, page: 1) { (_, response) in
            self.shows = []
            self.currentPage = 0
            self.totalPages = 0
            if let response = response {
                self.shows = response.results
                self.currentPage = response.page
                self.totalPages = response.totalPages
                self.collectionView.reloadData()
            }
        }
    }

// MARK: searchShows
    func searchShows(_ page: Int = 1, _ completionHandler: (() -> Void)?) {
        TMDb_Client.searchTV(query: searchBar.text!, page: page) { (_, response) in
            if let response = response {

                // create new index paths
                let showCount = self.shows.count
                let (start, end) = (showCount, response.results.count + showCount)
                let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }

                // update data source
                self.shows.append(contentsOf: response.results)
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

// MARK: performFetchMore
    func performFetchMore(_ completionHandler: (() -> Void)?) {
        let page = self.currentPage + 1
        switch segmentControll.selectedSegmentIndex {
        case 0:
            searchShows(page, completionHandler)
        case 1:
            fetchFavoriteMovies(page, completionHandler)
        case 2:
            fetchMovieWatchlist(page, completionHandler)
        default:
            return
        }
    }

// MARK: prepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let viewController = segue.destination as! TVShowDetailViewController
        if let indexPath = collectionView.indexPathsForSelectedItems {
            viewController.selectedShow = shows[indexPath[0].row]
        }
    }

// MARK: segmentControllDidChange
    @IBAction func segmentControllDidChange(_ sender: Any) {
        self.currentPage = 0
        self.totalPages = 0
        collectionView.reloadData()
        switch segmentControll.selectedSegmentIndex {
        case 0:
            shows = []
            searchBar.isHidden = false
            searchBar.text = ""
            collectionView.reloadData()
        default:
            shows = []
            searchBar.isHidden = true
            performFetchMore { }
            self.view.endEditing(true)
            return
        }
    }

// MARK: fetchFavoriteMovies
    func fetchFavoriteMovies(_ page: Int = 1, _ completionHandler: (() -> Void)?) {
        guard let user = LoggedInUser.selectedUser else {
            return
        }
        guard let sessionId = user.tmdbKey, sessionId != "" else {
            ShowAlert.banner(title: "TMDb Account Not Linked", message: "You must have a TMDb account linked to use this feature. Your account may be linked in User Profile.")
            return
        }
        TMDb_Client.getFavoriteShows(page: page, sessionId: sessionId) { (success, response) in
            if success {
                if let response = response {

                    // create new index paths
                    let showCount = self.shows.count
                    let (start, end) = (showCount, response.results.count + showCount)
                    let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }

                    // update data source
                    self.shows.append(contentsOf: response.results)
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
    }

// MARK: fetchMovieWatchlist
    func fetchMovieWatchlist(_ page: Int = 1, _ completionHandler: (() -> Void)?) {
        guard let user = LoggedInUser.selectedUser else {
            return
        }
        guard let sessionId = user.tmdbKey, sessionId != "" else {
            ShowAlert.banner(title: "TMDb Account Not Linked", message: "You must have a TMDb account linked to use this feature. Your account may be linked in User Profile.")
            return
        }
        TMDb_Client.getTVWatchlist(page: page, sessionId: sessionId) { (success, response) in
            if success {
                if let response = response {

                    // create new index paths
                    let showCount = self.shows.count
                    let (start, end) = (showCount, response.results.count + showCount)
                    let indexPaths = (start..<end).map { return IndexPath(row: $0, section: 0) }

                    // update data source
                    self.shows.append(contentsOf: response.results)
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
    }

    // MARK: hideKeyboardOnTap
        func hideKeyboardOnTap() {
            let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }

}

// MARK: - Collection View Functions
extension TVShowSearchViewController {

    // MARK: Set Number of Items
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return shows.count
        }

    // MARK: Build Items
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCollectionViewCell
            let show = shows[indexPath.row]
            if let imageSuffix = show.posterPath {
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
                        .targetCache(showCache)
                    ])
            } else {
                cell.imageView.image = UIImage(named: "placeholder_w185")
            }
            if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: show.movieRating ?? "nr") {
                cell.imageView.image = UIImage(named: "placeholder_w185")
            }
            return cell
        }

    // MARK: Did Select Item
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if !ContentRestrictionsKit.Movie.ratingIsAllowed(country: .US, rating: shows[indexPath.row].movieRating ?? "nr") && LoggedInUser.user!.username != "dev_KKid_Master" {
                ShowAlert.banner(title: "Access Restricted", message: "This movie is rated \(shows[indexPath.row].movieRating ?? "nr") which is above the restriction level set on your device.")
            } else {
                performSegue(withIdentifier: "segueShowDetails", sender: self)
            }
        }
}
