//
//  CompletedTasksViewController.swift
//  CoreDataMyTappsks
//
//  Created by Hugo Huichalao on 28-07-24.
//

import UIKit
import CoreData

class CompletedTasksViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: "completedCell")
        return table
    }()
    
    private var models = [ToDoListItem]()
    private var categories = [Category]()
    private var groupedItems = [Category: [ToDoListItem]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllItems()
        getAllCategories()
        title = "Completed Tasks"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
    }

    
    private func groupItemsByCategory() {
        groupedItems.removeAll()
        for item in models {
            if let category = item.category {
                if groupedItems[category] == nil {
                    groupedItems[category] = []
                }
                groupedItems[category]?.append(item)
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return groupedItems.keys.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let category = Array(groupedItems.keys)[section]
        return groupedItems[category]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = Array(groupedItems.keys)[indexPath.section]
        let model = groupedItems[category]![indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "completedCell", for: indexPath) as! CustomTableViewCell
        
        cell.nameLabel.text = model.name
        if let completedAt = model.completedAt {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            cell.detailLabel.text = dateFormatter.string(from: completedAt)
        } else {
            cell.detailLabel.text = ""
        }
        
        cell.toggleButton.setTitle(model.completed ? "✅" : "◻️", for: .normal)
        cell.toggleButton.addTarget(self, action: #selector(toggleCompleted(_:)), for: .touchUpInside)
        cell.toggleButton.tag = indexPath.section * 1000 + indexPath.row  // Usar tag para identificar la celda
        
        return cell
    }
    
    @objc private func toggleCompleted(_ sender: UIButton) {
        let section = sender.tag / 1000
        let row = sender.tag % 1000
        let category = Array(groupedItems.keys)[section]
        let item = groupedItems[category]![row]
        
        item.completed.toggle()
        
        do {
            try context.save()
            getAllItems()
            tableView.reloadData()
        } catch {
            // Manejo de errores
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = Array(groupedItems.keys)[section]
        return category.name
    }
    
    // CoreData
    
    func getAllItems() {
        do {
            let request: NSFetchRequest<ToDoListItem> = ToDoListItem.fetchRequest()
            request.predicate = NSPredicate(format: "completed == %@", NSNumber(value: true))
            models = try context.fetch(request)
            groupItemsByCategory()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            // Manejo de errores
        }
    }
    
    func getAllCategories() {
        do {
            categories = try context.fetch(Category.fetchRequest())
        } catch {
            // Manejo de errores
        }
    }
}
