//
//  ProfileViewController.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 15.10.2022.
//

import UIKit
import SnapKit

class ProfileViewController: UIViewController, ProfileViewProtocol {

    var presenter: ProfilePresenterProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let lbl = UILabel()
        lbl.text = "Профиль"
        lbl.textAlignment = .center
        lbl.textColor = .black
        lbl.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(lbl)
        lbl.snp.makeConstraints{ maker in
            maker.top.equalToSuperview().offset(100)
            maker.leading.equalToSuperview().offset(20)
            maker.trailing.equalToSuperview().inset(20)
            maker.height.equalTo(25)
        }
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
