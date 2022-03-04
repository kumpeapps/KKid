//
//  MovieDetailViewController.swift
//  KMovies
//
//  Created by Justin Kumpe on 11/28/20.
//

import Foundation
import UIKit
import Kingfisher
import KumpeHelpers
import YoutubeKit

class MovieDetailViewController: UIViewController, YTSwiftyPlayerDelegate {

// MARK: scrollViews
    @IBOutlet weak var scrollView: UIScrollView!

// MARK: playerViews
    @IBOutlet weak var playerView: UIView!
    var player: YTSwiftyPlayer!

// MARK: labels
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelReleaseDate: UILabel!
    @IBOutlet weak var labelRating: UILabel!
    @IBOutlet weak var labelOverview: UILabel!
    @IBOutlet weak var textOverview: UILabel!

// MARK: buttons
    @IBOutlet weak var imageBackground: UIButton!
    @IBOutlet weak var buttonMovieRating: UIButton!
    @IBOutlet weak var buttonTmdb: UIButton!
    @IBOutlet weak var buttonFavorite: UIButton!
    @IBOutlet weak var buttonWatchList: UIButton!

// MARK: images
    @IBOutlet weak var imageMovieRating: UIImageView!

// MARK: properties
    var selectedMovie: TMDb_Movie!
    var trailerKey: String = ""

// MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isDirectionalLockEnabled = true
    }

// MARK: viewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        labelTitle.text = selectedMovie.title ?? "Unknown Title"
        labelReleaseDate.text = "Release Date: \(selectedMovie.releaseDate ?? "Unknown")"
        labelRating.text = "Score: \(selectedMovie.voteAverage ?? 0)/10"
        textOverview.text = selectedMovie.overview ?? ""
        if trailerKey == "" {
            playerView.isHidden = true
            imageBackground.isHidden = false
        }
        if let backgroundImage = selectedMovie.backdropPath {
            let imageUrl = URL(string: "\(TMDb_Constants.BackDropUrl.w780.baseUrl)\(backgroundImage)")
            imageBackground.kf.setBackgroundImage(with: imageUrl, for: .normal)
        }
    }

// MARK: viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getMovieRating()
        getFavorites()
        getWatchlist()
    }

// MARK: viewWillDisappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if player != nil {
            player.stopVideo()
        }
    }

// MARK: getMovieRating
    func getMovieRating() {
        self.imageMovieRating.kf.setImage(with: MovieRating.init(rawValue: selectedMovie.movieRating!)?.url)
        getMovieTrailer()
    }

// MARK: getMovieTrailer
    func getMovieTrailer() {
        TMDb_Client.getMovieTrailer(movie: selectedMovie) { (success, trailerKey) in
            if success {
                self.trailerKey = trailerKey!
                self.buildVideoPlayer()
            }
        }
    }

// MARK: buildVideoPlayer
    func buildVideoPlayer() {
        player = YTSwiftyPlayer(
            frame: CGRect(x: 0, y: 0, width: playerView.bounds.width, height: playerView.bounds.height),
            playerVars: [.videoID(trailerKey), .playsInline(true), VideoEmbedParameter.showRelatedVideo(false)])
        player.autoplay = true
        player.delegate = self
        playerView.addSubview(player)
        player.autoplay = true
        #if !targetEnvironment(simulator)
            playVideo()
        #endif
    }

// MARK: playVideo
    func playVideo() {
        player.loadPlayer()
        player.loadVideo(contentURL: "\(TMDb_Constants.trailerBaseURL)\(self.trailerKey)")
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.x>0 {
            scrollView.contentOffset.x = 0
        }
    }

// MARK: player: didChangeState
    func player(_ player: YTSwiftyPlayer, didChangeState state: YTSwiftyPlayerState) {
        switch state {
        case .ended:
            hidePlayer(true)
        case .playing:
            hidePlayer(false)
        case .unstarted:
            return
        case .paused:
            return
        case .buffering:
            hidePlayer(false)
        case .cued:
            return
        }
    }

// MARK: hidePlayer
    func hidePlayer(_ hide: Bool) {
        imageBackground.isHidden = !hide
        playerView.isHidden = hide
    }

// MARK: pressedBackgroundImage
    @IBAction func pressedBackgroundImage(_ sender: Any) {
        if player != nil {
            playVideo()
        }
    }

    @IBAction func pressedFavorite(_ sender: Any) {
        guard let user = LoggedInUser.selectedUser else {
            return
        }
        guard let sessionId = user.tmdbKey, sessionId != "" else {
            ShowAlert.banner(title: "TMDb Account Not Linked", message: "This feature requires a TMDb account to be linked to this user via edit profile.")
            return
        }
        selectedMovie.favorite = !selectedMovie.favorite!
        updateFavoriteButton(selectedMovie.favorite!)
        TMDb_Client.postFavorite(sessionId: sessionId, mediaType: "movie", mediaId: selectedMovie.id!, favorite: selectedMovie.favorite!) { (success) in
            if success {
                Logger.log(.success, "marked as favorite \(self.selectedMovie.favorite!)")
            } else {
                Logger.log(.error, "mark as favorite error")
            }
        }
    }

    @IBAction func pressedWatchList(_ sender: Any) {
        guard let user = LoggedInUser.selectedUser else {
            return
        }
        guard let sessionId = user.tmdbKey, sessionId != "" else {
            ShowAlert.banner(title: "TMDb Account Not Linked", message: "This feature requires a TMDb account to be linked to this user via edit profile.")
            return
        }
        selectedMovie.watchList = !selectedMovie.watchList!
        updateWatchlistButton(selectedMovie.watchList!)
        TMDb_Client.postWatchlist(sessionId: sessionId, mediaType: "movie", mediaId: selectedMovie.id!, watchlist: selectedMovie.watchList!) { (success) in
            if success {
                Logger.log(.success, "marked as watchList \(self.selectedMovie.watchList!)")
            } else {
                Logger.log(.error, "mark as watchList error")
            }
        }
    }

    // MARK: updateFavoriteButton
    func updateFavoriteButton(_ favorite: Bool) {
        if favorite {
            buttonFavorite.alpha = 1
        } else {
            buttonFavorite.alpha = 0.5
        }
    }

    // MARK: updateWatchlistButton
    func updateWatchlistButton(_ watchlist: Bool) {
        if watchlist {
            buttonWatchList.alpha = 1
        } else {
            buttonWatchList.alpha = 0.5
        }
    }

    // MARK: getFavorites
    func getFavorites() {
        guard let sessionID = LoggedInUser.selectedUser!.tmdbKey, sessionID != "" else {
            return
        }
        let movieID = selectedMovie.id
        selectedMovie.favorite = false
        TMDb_Client.getFavoriteMovies(sessionId: sessionID) { (success, response) in
            if success {
                guard let movies = response?.results else {
                    return
                }
                for movie in movies where movie.id == movieID {
                        self.selectedMovie.favorite = true
                        self.updateFavoriteButton(true)
                }
            }
        }
    }

    // MARK: getWatchlist
    func getWatchlist() {
        guard let sessionID = LoggedInUser.selectedUser!.tmdbKey, sessionID != "" else {
            return
        }
        let movieID = selectedMovie.id
        selectedMovie.watchList = false
        TMDb_Client.getMovieWatchlist(sessionId: sessionID) { (success, response) in
            if success {
                guard let movies = response?.results else {
                    return
                }
                for movie in movies where movie.id == movieID {
                        self.selectedMovie.watchList = true
                        self.updateWatchlistButton(true)
                }
            }
        }
    }

}
