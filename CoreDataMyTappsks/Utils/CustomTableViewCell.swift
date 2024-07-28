import UIKit

class CustomTableViewCell: UITableViewCell {
    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .gray
        return label
    }()
    
    let toggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(toggleButton)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -10),
            
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 5),
            detailLabel.trailingAnchor.constraint(equalTo: toggleButton.leadingAnchor, constant: -10),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            toggleButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            toggleButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            toggleButton.widthAnchor.constraint(equalToConstant: 30),
            toggleButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
