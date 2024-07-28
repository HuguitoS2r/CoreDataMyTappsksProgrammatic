//
//  TaskListView.swift
//  CoreDataMyTappsks
//
//  Created by Hugo Huichalao on 28-07-24.
//

import Foundation

protocol TaskListView: AnyObject {
    func displayTasks(_ tasks: [ToDoListItem])
    func displayError(_ error: String)
}

