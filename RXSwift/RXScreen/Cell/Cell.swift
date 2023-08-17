//
//  Cell.swift
//  RXSwift
//

import SnapKit
import UIKit

final class Cell: UITableViewCell {
    
    var title = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
    }
    
    private func setupLayout() {
        contentView.addSubview(title)
        
        title.snp.makeConstraints { maker in
            maker.leading.trailing.equalToSuperview().offset(12)
            maker.top.bottom.equalToSuperview().inset(12)
        }
    }
}
