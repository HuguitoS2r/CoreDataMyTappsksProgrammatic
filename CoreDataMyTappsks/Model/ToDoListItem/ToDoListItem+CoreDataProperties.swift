//
//  ToDoListItem+CoreDataProperties.swift
//  CoreDataMyTappsks
//
//  Created by Hugo Huichalao on 28-07-24.
//
//

import Foundation
import CoreData


extension ToDoListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ToDoListItem> {
        return NSFetchRequest<ToDoListItem>(entityName: "ToDoListItem")
    }

    @NSManaged public var createdAt: Date?
    @NSManaged public var name: String?
    @NSManaged public var completed: Bool
    @NSManaged public var completedAt: Date?
    @NSManaged public var category: Category?

}

extension ToDoListItem : Identifiable {

}
