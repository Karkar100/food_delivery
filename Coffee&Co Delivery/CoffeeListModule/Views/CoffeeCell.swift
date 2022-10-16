//
//  CoffeeCell.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 15.10.2022.
//

import Foundation
import UIKit
import SnapKit

protocol CoffeeCellDelegate {
   
    func changeNumber(cell: CoffeeCell, number: Int)
}

class CoffeeCell: UITableViewCell {
    var delegate: CoffeeCellDelegate?
    static let reuseId = "reuseId"
    let titleLabel: UILabel = {
        
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        lbl.textColor = UIColor(hex: "#222831")
        lbl.textAlignment = .left
        return lbl
    }()
    let descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        lbl.textColor = UIColor(hex: "#AAAAAD")
        return lbl
    }()
    let coffeeImage: UIImageView = {
        let imgV = UIImageView()
        imgV.contentMode = .scaleAspectFit
        imgV.clipsToBounds = true
        imgV.layer.cornerRadius = imgV.frame.height/2
        return imgV
    }()
    let orderButton: UIButton = {
        let button = UIButton()
        let attr = NSAttributedString(string: "Заказать", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hex: "#FD3A69"), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .regular)])
        button.setAttributedTitle(attr, for: .normal)
        button.addBorders(borderWidth: 1, borderColor: UIColor(hex: "#FD3A69").cgColor)
        button.clipsToBounds = true
        button.layer.cornerRadius = 6
        return button
    }()
    let minusButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(systemName: "minus.circle")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    let plusButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(systemName: "plus.circle")
        button.setImage(image, for: .normal)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    let quantityLabel : UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = .center
        lbl.attributedText = NSAttributedString(string: "1", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hex: "#FD3A69"), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .regular)])
        return lbl
    }()
    var coffeeQuantity: Int?
    var quantityStack: UIStackView?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        coffeeQuantity = 1
        placeSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func placeSubviews(){
        addSubview(coffeeImage)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        orderButton.addTarget(self, action: #selector(showStack(_:)), for: .touchUpInside)
        //minusButton.addTarget(self, action: #selector(deductOne(_:)), for: .touchUpInside)
        //plusButton.addTarget(self, action: #selector(addOne(_:)), for: .touchUpInside)
        contentView.addSubview(orderButton)
    }
    
    func setupConstraints(){
        coffeeImage.snp.makeConstraints{ maker in
            maker.top.equalToSuperview().offset(16)
            maker.leading.equalToSuperview().offset(16)
            maker.width.height.equalTo(132)
        }
        titleLabel.snp.makeConstraints{ maker in
            maker.top.equalToSuperview().offset(20)
            maker.trailing.equalToSuperview().inset(27)
            maker.height.equalTo(20)
            maker.width.equalTo(168)
        }
        descriptionLabel.snp.makeConstraints{ maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(8)
            maker.trailing.equalToSuperview().inset(24)
            maker.height.equalTo(64)
            maker.width.equalTo(171)
        }
        orderButton.snp.makeConstraints{ maker in
            maker.trailing.equalToSuperview().inset(24)
            maker.top.equalTo(descriptionLabel.snp.bottom).offset(16)
            maker.width.equalTo(87)
            maker.height.equalTo(32)
        }
    }
    
    @objc func showStack(_ sender: UIButton){
        DispatchQueue.main.async {
            self.minusButton.addTarget(self, action: #selector(self.deductOne(_:)), for: .touchUpInside)
            self.plusButton.addTarget(self, action: #selector(self.addOne(_:)), for: .touchUpInside)
            self.quantityStack = UIStackView(arrangedSubviews: [self.minusButton, self.quantityLabel, self.plusButton])
            self.quantityStack?.distribution = .equalSpacing
            self.quantityStack?.axis = .horizontal
            self.quantityStack?.spacing = 6
            self.orderButton.removeFromSuperview()
            self.addSubview(self.quantityStack!)
            self.quantityStack?.snp.makeConstraints{ maker in
                maker.trailing.equalToSuperview().inset(24)
                maker.top.equalTo(self.descriptionLabel.snp.bottom).offset(16)
                maker.width.equalTo(87)
                maker.height.equalTo(25)
            }
        }
    }
    
    @objc func deductOne(_ sender: UIButton){
        changeQuantity(by: -1)
    }
    
    @objc func addOne(_ sender: UIButton){
        changeQuantity(by: 1)
    }
    
    func changeQuantity(by number: Int) {
        var quantity = coffeeQuantity ?? 1
        quantity += number
        if quantity < 1{
            quantity = 1
            quantityStack?.removeFromSuperview()
            orderButtonReappear()
        } else {
            DispatchQueue.main.async {
                self.quantityLabel.attributedText = NSAttributedString(string: "\(quantity)", attributes: [NSAttributedString.Key.foregroundColor : UIColor(hex: "#FD3A69"), NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .regular)])
            }
        }
        delegate?.changeNumber(cell: self, number: quantity)
        coffeeQuantity = quantity
    }
    
    func orderButtonReappear(){
        DispatchQueue.main.async {
            self.orderButton.addTarget(self, action: #selector(self.showStack(_:)), for: .touchUpInside)
            self.addSubview(self.orderButton)
            self.orderButton.snp.makeConstraints{ maker in
                maker.trailing.equalToSuperview().inset(24)
                maker.top.equalTo(self.descriptionLabel.snp.bottom).offset(16)
                maker.width.equalTo(87)
                maker.height.equalTo(32)
            }
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(title: String, description: String, image: UIImage){
        coffeeImage.image = image
        titleLabel.text = title
        descriptionLabel.text = description
    }
}
