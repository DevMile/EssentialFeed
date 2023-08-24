//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Milan Bojic on 24.8.23..
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
