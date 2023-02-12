//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Milan Bojic on 11.2.23..
//

import UIKit
import EssentialFeed

public final class FeedUIComposer {
    private init() {}
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let feedViewModel = FeedViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(viewModel: feedViewModel)
        let feedController = FeedViewController(refreshController: refreshController)
        feedViewModel.onFeedLoad = { [weak feedController] feed in
            feedController?.tableModel = feed.map { model in
                FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader))
            }
        }
        return feedController
    }
    
    // Adapter pattern - mapping [FeedImage] into FeedImageController - we can write also like this:
    // feedViewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
    
//    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewController, loader: FeedImageDataLoader) -> ([FeedImage]) -> Void {
//        return { [weak controller] feed in
//            controller?.tableModel = feed.map { model in
//                FeedImageCellController(viewModel: FeedImageViewModel(model: model, imageLoader: imageLoader))
//            }
//        }
//    }
}
