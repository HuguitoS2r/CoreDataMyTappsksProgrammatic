import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TaskListView {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [ToDoListItem]()
    private var categories = [Category]()
    private var groupedItems = [Category: [ToDoListItem]]()
    private var presenter: TaskListPresenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter = TaskListPresenter(view: self)
        presenter.fetchTasks()
        getAllCategories()

        title = "CoreData Tappsks"
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 60
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(didTapAddCategory)),
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTapRecord))
        ]
    }

    func displayTasks(_ tasks: [ToDoListItem]) {
        self.models = tasks
        groupItemsByCategory()
        tableView.reloadData()
    }

    func displayError(_ error: String) {
        // Handle error presentation
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
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
    
    @objc private func didTapAdd() {
        let customVC = CustomAddItemViewController()
        customVC.categories = categories
        customVC.modalPresentationStyle = .overFullScreen
        customVC.modalTransitionStyle = .crossDissolve
        customVC.onSubmit = { [weak self] name, category in
            self?.presenter.createTask(name: name, category: category)
        }
        present(customVC, animated: true, completion: nil)
    }

    @objc private func didTapAddCategory() {
        let vc = CategoriesViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func didTapRecord() {
        let vc = CompletedTasksViewController()
        navigationController?.pushViewController(vc, animated: true)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let category = Array(groupedItems.keys)[indexPath.section]
        let item = groupedItems[category]![indexPath.row]
        
        let sheet = UIAlertController(title: "Edit", message: nil, preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak self] _ in
            self?.presentEditItemViewController(item: item)
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.presenter.deleteTask(item: item)
        }))
        
        present(sheet, animated: true)
    }

    private func presentEditItemViewController(item: ToDoListItem) {
        let customVC = CustomAddItemViewController()
        customVC.categories = categories
        customVC.itemToEdit = item
        customVC.modalPresentationStyle = .overFullScreen
        customVC.modalTransitionStyle = .crossDissolve
        customVC.onSubmit = { [weak self] name, category in
            guard let strongSelf = self else { return }
            strongSelf.presenter.updateTask(item: item, newName: name, newCategory: category)
        }
        present(customVC, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        
        cell.nameLabel.text = model.name
        
        // Remueve el detailLabel ya que no se necesita
        cell.detailLabel.text = ""
        cell.detailLabel.isHidden = true
        
        // Configura el toggleButton
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
        
        if item.completed {
            item.completedAt = Date()
        } else {
            item.completedAt = nil
        }
        
        do {
            try context.save()
            presenter.fetchTasks()
        } catch {
            // Manejo de errores
            displayError("Failed to update task")
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
