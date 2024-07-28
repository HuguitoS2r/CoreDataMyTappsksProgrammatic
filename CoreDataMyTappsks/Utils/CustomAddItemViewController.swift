import UIKit
import CoreData

class CustomAddItemViewController: UIViewController {
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 13
        view.clipsToBounds = true
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "New Item"
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textAlignment = .center
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Enter new item"
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let textField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.font = .systemFont(ofSize: 13)
        return textField
    }()
    
    private let pickerView: UIPickerView = {
        let picker = UIPickerView()
        return picker
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        return button
    }()
    
    private let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        return view
    }()
    
    var categories: [Category] = []
    var onSubmit: ((String, Category?) -> Void)?
    var itemToEdit: ToDoListItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        configureForEditing()
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.addSubview(contentView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(textField)
        contentView.addSubview(pickerView)
        contentView.addSubview(buttonStackView)
        contentView.addSubview(separatorView)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(submitButton)
        
        pickerView.dataSource = self
        pickerView.delegate = self
    }
    
    private func setupConstraints() {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contentView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            contentView.widthAnchor.constraint(equalToConstant: 270),
            
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 32),
            
            pickerView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            pickerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            pickerView.heightAnchor.constraint(equalToConstant: 120),
            
            separatorView.topAnchor.constraint(equalTo: pickerView.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            
            buttonStackView.topAnchor.constraint(equalTo: separatorView.bottomAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func submitTapped() {
        guard let text = textField.text, !text.isEmpty else { return }
        if !hasCategoriesAvailable() {
            showNoCategoriesAlert()
            return
        }
        let selectedCategory = getSelectedCategory()
        onSubmit?(text, selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
    private func showNoCategoriesAlert() {
        let alert = UIAlertController(title: "No Categories", message: "Please add a category before creating an item.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func getSelectedCategory() -> Category? {
        guard !categories.isEmpty else { return nil }
        let selectedRow = pickerView.selectedRow(inComponent: 0)
        return categories[selectedRow]
    }
    
    private func hasCategoriesAvailable() -> Bool {
        return !categories.isEmpty
    }
    
    private func configureForEditing() {
        if let item = itemToEdit {
            titleLabel.text = "Edit Item"
            messageLabel.text = "Update your item"
            textField.text = item.name
            if let category = item.category, let index = categories.firstIndex(of: category) {
                pickerView.selectRow(index, inComponent: 0, animated: false)
            }
        }
    }
}

extension CustomAddItemViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.isEmpty ? 0 : categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row].name
    }
}
