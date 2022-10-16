//
//  CoffeeListViewController.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 13.10.2022.
//

import UIKit
import Network
import SnapKit

class CoffeeListViewController: UIViewController, CoffeeListViewProtocol {
    
    let cityLabel: UILabel = {
        let lbl = UILabel()
        lbl.numberOfLines = 0
        lbl.lineBreakMode = .byWordWrapping
        lbl.textAlignment = .left
        lbl.attributedText = NSAttributedString(string: "Москва", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)])
        return lbl
    }()
    let arrowDownImage: UIImageView = {
        let img = UIImageView()
        img.contentMode = .scaleAspectFit
        img.image = UIImage(systemName: "control")
        return img
    }()
    let dropDown = CityDropDown()
    var dropDownRowHeight: CGFloat = 26
    let bannerContainerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 10.0
        return view
    }()
    let upperView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    let lowerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 10.0
        view.backgroundColor = UIColor.white
        return view
    }()
    let tableView = UITableView(frame: .zero, style: .plain)
    let hotButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 18.0
        return button
    }()
    let icedButton: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.layer.cornerRadius = 18.0
        return button
    }()
    var buttonStack: UIStackView?
    var scrollView = UIScrollView()
    
    var presenter: CoffeeListPresenterProtocol?
    var pageVC: BannerViewController!
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "InternetConnectionMonitor")
    var activityIndicator = UIActivityIndicatorView(style: .large)
    var icedSectionOpened = false
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: "#F3F5F9")
        monitor.pathUpdateHandler = { pathUpdateHandler in
                    if pathUpdateHandler.status == .satisfied {
                        print("Internet connection is on.")
                    } else {
                        DispatchQueue.main.async {
                                self.noInternet()
                        }
                    }
                }
        monitor.start(queue: queue)
        initialConfig()
        
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDown()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    func initialConfig(){
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(repeatRequest(_:)))
        swipeDown.direction = .down
        swipeDown.numberOfTouchesRequired = 1
        view.addGestureRecognizer(swipeDown)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        let activityCenterX = NSLayoutConstraint(item: activityIndicator, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let activityCenterY = NSLayoutConstraint(item: activityIndicator, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([activityCenterX, activityCenterY])
        activityIndicator.startAnimating()
        arrowDownImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        view.addSubview(upperView)
        upperView.snp.makeConstraints{ maker in
            maker.top.leading.trailing.equalToSuperview()
            maker.height.equalTo(292.74)
        }
        upperView.addSubview(cityLabel)
        upperView.addSubview(arrowDownImage)
        setUpGestures()
        cityLabel.snp.makeConstraints{ maker in
            maker.top.equalToSuperview().offset(46.74)
            maker.leading.equalToSuperview().offset(16)
            maker.height.equalTo(20)
            maker.width.equalTo(61)
        }
        arrowDownImage.snp.makeConstraints{ maker in
            maker.top.equalTo(cityLabel.snp.top).offset(8)
            maker.leading.equalTo(cityLabel.snp.trailing).offset(4)
            maker.width.equalTo(8)
            maker.height.equalTo(14)
        }
    }
    
    func configureViews() {
        pageVC = BannerViewController()
        pageVC.dataSource = presenter
        pageVC.delegate = presenter
        let array = presenter?.formBanners()
        pageVC.setViewControllers([array![0]], direction: .forward, animated: true, completion: nil)
        addChild(pageVC)
        upperView.addSubview(bannerContainerView)
        bannerContainerView.addSubview(pageVC.view)
        paintButtons(id: 0)
        hotButton.addTarget(self, action: #selector(hotButtonTapped(_:)), for: .touchUpInside)
        icedButton.addTarget(self, action: #selector(icedButtonTapped(_:)), for: .touchUpInside)
        buttonStack = UIStackView(arrangedSubviews: [hotButton, icedButton])
        buttonStack?.axis = .horizontal
        buttonStack?.distribution = .fillEqually
        buttonStack?.alignment = .fill
        buttonStack?.spacing = 8
        upperView.addSubview(buttonStack!)
        view.addSubview(lowerView)
        tableView.register(CoffeeCell.self, forCellReuseIdentifier: CoffeeCell.reuseId)
        tableView.dataSource = presenter
        tableView.delegate = presenter
        lowerView.addSubview(tableView)
        pageVC.didMove(toParent: self)
    }
    
    func setupConstraints() {
        bannerContainerView.snp.makeConstraints{ maker in
            maker.top.equalToSuperview().offset(90.74)
            maker.leading.equalToSuperview().offset(16)
            maker.trailing.equalToSuperview().inset(16)
            maker.height.equalTo(122)
        }
        pageVC.view.snp.makeConstraints{ maker in
            maker.edges.equalToSuperview()
        }
        buttonStack?.snp.makeConstraints{ maker in
            maker.top.equalTo(bannerContainerView.snp.bottom).offset(24)
            maker.leading.equalToSuperview().offset(16)
            maker.width.equalTo(184)
            maker.height.equalTo(34)
        }
        lowerView.snp.makeConstraints{ maker in
            maker.top.equalTo(buttonStack!.snp.bottom).offset(24)
            maker.leading.trailing.bottom.equalToSuperview()
        }
        tableView.snp.makeConstraints{ maker in
            maker.edges.equalToSuperview()
        }
    }
    
    func setUpDropDown(){
        dropDown.makeDropDownIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.makeDropDownDataSourceProtocol = presenter
        dropDown.setUpDropDown(viewPositionReference: (cityLabel.frame), offset: 2)
        dropDown.nib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        dropDown.width = self.view.frame.width/2
        self.view.addSubview(dropDown)
    }
    
    func setUpGestures(){
        self.cityLabel.isUserInteractionEnabled = true
        let cityLabelTapGesture = UITapGestureRecognizer(target: self, action: #selector(dropDownCall(_:)))
        self.cityLabel.addGestureRecognizer(cityLabelTapGesture)
        self.arrowDownImage.isUserInteractionEnabled = true
        let arrowDownImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(dropDownCall(_:)))
        self.arrowDownImage.addGestureRecognizer(arrowDownImageTapGesture)
    }
    
    func paintButtons(id: Int){
        let backColor = UIColor(hex: "#FD3A69").withAlphaComponent(0.2)
        let typeColor = UIColor(hex: "#FD3A69")
        let borderColor = UIColor(hex: "#FD3A69").withAlphaComponent(0.4)
        let hotButtonStr = "Горячие"
        let icedButtonStr = "Холодные"
        switch id {
        case 0:
            hotButton.backgroundColor = backColor
            icedButton.backgroundColor = .clear
            icedButton.addBorders(borderWidth: 1, borderColor: borderColor.cgColor)
            let hotButtonTitle = NSAttributedString(string: hotButtonStr, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .bold), NSAttributedString.Key.foregroundColor : typeColor])
            hotButton.setAttributedTitle(hotButtonTitle, for: .normal)
            let icedButtonTitle = NSAttributedString(string: icedButtonStr, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .regular), NSAttributedString.Key.foregroundColor : borderColor])
            icedButton.setAttributedTitle(icedButtonTitle, for: .normal)
        case 1:
            icedButton.backgroundColor = backColor
            hotButton.backgroundColor = .clear
            hotButton.addBorders(borderWidth: 1, borderColor: borderColor.cgColor)
            let icedButtonTitle = NSAttributedString(string: icedButtonStr, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .bold), NSAttributedString.Key.foregroundColor : typeColor])
            icedButton.setAttributedTitle(icedButtonTitle, for: .normal)
            let hotButtonTitle = NSAttributedString(string: hotButtonStr, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 13, weight: .regular), NSAttributedString.Key.foregroundColor : borderColor])
            hotButton.setAttributedTitle(hotButtonTitle, for: .normal)
        default:
            break
        }
    }
    
    func reload() {
        DispatchQueue.main.async {
            if self.activityIndicator.isAnimating{
                self.activityIndicator.stopAnimating()
            }
            self.configureViews()
            self.setupConstraints()
            self.tableView.reloadData()
        }
    }
    
    func noInternet(){
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Отсутствует соединение с интернетом", message: "Пожалуйста, проверьте подключение и повторите попытку.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func requestFailure(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "При выполнении запроса произошла ошибка", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func changeCity(city: String) {
        DispatchQueue.main.async {
            self.cityLabel.attributedText = NSAttributedString(string: city, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17)])
            self.dropDown.hideDropDown()
            self.arrowDownImage.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        }
    }
    
    @objc func hotButtonTapped(_ sender: UIButton){
        paintButtons(id: 0)
        if icedSectionOpened{
            moveTableView(section: 0)
            icedSectionOpened = false
        }
    }
    
    @objc func icedButtonTapped(_ sender: UIButton){
        paintButtons(id: 1)
        if !icedSectionOpened{
            moveTableView(section: 1)
            icedSectionOpened = true
        }
    }
    
    @objc func repeatRequest(_ sender: UISwipeGestureRecognizer){
        monitor.pathUpdateHandler = { pathUpdateHandler in
                    if pathUpdateHandler.status == .satisfied {
                        self.presenter?.repeatRequest()
                    } else {
                        DispatchQueue.main.async {
                                self.noInternet()
                        }
                    }
                }
        monitor.start(queue: queue)
    }
    
    func adjustHeight(){
        DispatchQueue.main.async {
            self.bannerContainerView.removeFromSuperview()
            self.upperView.snp.remakeConstraints{ maker in
                maker.top.leading.trailing.equalToSuperview()
                maker.height.equalTo(172.74)
            }
            self.buttonStack?.snp.remakeConstraints{ maker in
                maker.top.equalTo(self.cityLabel.snp.bottom).offset(24)
                maker.leading.equalToSuperview().offset(16)
                maker.width.equalTo(184)
                maker.height.equalTo(32)
            }
        }
    }
    
    func rebuildBanners() {
        DispatchQueue.main.async {
            self.upperView.addSubview(self.bannerContainerView)
            self.bannerContainerView.addSubview(self.pageVC.view)
            self.upperView.snp.remakeConstraints{ maker in
                maker.top.leading.trailing.equalToSuperview()
                maker.height.equalTo(292.74)
            }
            self.bannerContainerView.snp.makeConstraints{ maker in
                maker.top.equalToSuperview().offset(90.74)
                maker.leading.equalToSuperview().offset(16)
                maker.trailing.equalToSuperview().inset(16)
                maker.height.equalTo(122)
            }
            self.pageVC.view.snp.makeConstraints{ maker in
                maker.edges.equalToSuperview()
            }
            self.buttonStack?.snp.remakeConstraints{ maker in
                maker.top.equalTo(self.bannerContainerView.snp.bottom).offset(24)
                maker.leading.equalToSuperview().offset(16)
                maker.width.equalTo(184)
                maker.height.equalTo(34)
            }
        }
    }
    
    func moveTableView(section: Int) {
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: section)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    @objc func dropDownCall(_ sender: UITapGestureRecognizer){
        DispatchQueue.main.async {
            self.dropDown.showDropDown(height: self.dropDownRowHeight * 7)
            self.arrowDownImage.transform = CGAffineTransform.identity
        }
    }
}

