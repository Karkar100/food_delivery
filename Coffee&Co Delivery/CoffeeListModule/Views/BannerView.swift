//
//  BannerView.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 14.10.2022.
//

import UIKit
import SnapKit

class BannerView: UIView {
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.layer.cornerRadius = 10
        return imgView
    }()
    
    init(image: UIImage) {
        super.init(frame: .zero)
        configureViews(image: image)
        setupConstraints()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureViews(image: UIImage) {
        imageView.image = image
        addSubview(imageView)
    }
    
    func setupConstraints() {
        imageView.snp.makeConstraints{ maker in
            maker.edges.equalToSuperview()
        }
    }
    
}
