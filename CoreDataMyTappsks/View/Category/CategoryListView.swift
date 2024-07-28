//
//  CategoryListView.swift
//  CoreDataMyTappsks
//
//  Created by Hugo Huichalao on 28-07-24.
//

import Foundation

protocol CategoryListView: AnyObject {
    func displayCategories(_ categories: [Category])
    func displayError(_ error: String)
}
