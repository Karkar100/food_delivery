//
//  CoffeeListPresenter.swift
//  Coffee&Co Delivery
//
//  Created by Diana Princess on 13.10.2022.
//

import Foundation
import UIKit
import CoreData

protocol CoffeeListViewProtocol: class {
    
    func noInternet()
    func requestFailure(error: Error)
    func reload()
    func changeCity(city: String)
    func adjustHeight()
    func rebuildBanners()
}

protocol CoffeeListPresenterProtocol: class, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, DropDownDataSourceProtocol{
    init(view: CoffeeListViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol)
    func formBanners()->[UIViewController]
    func repeatRequest()
    func fetchCoffees()
    
}

class CoffeeListPresenter: NSObject, CoffeeListPresenterProtocol {
    var view: CoffeeListViewProtocol?
    let networkService: NetworkServiceProtocol!
    var router: RouterProtocol?
    var coffeeList: [[CoffeeModel]] = []
    var coffeeImages: [[UIImage]] = []
    var tempList: [CoffeeModel]?
    var downloadedCoffees: [[NSManagedObject]] = []
    var tempDownloaded: [NSManagedObject] = []
    var itemsCount: [Int] = []
    var heightAdjusted = false
    var banners: [UIViewController] = [UIViewController]()
    let bannerPhotos = [
        UIImage(named: "banner1")!,
        UIImage(named: "banner2")!,
        UIImage(named: "banner3")!
    ]
    let cities = ["Москва", "Санкт-Петербург", "Казань", "Екатеринбург", "Омск", "Челябинск", "Самара"]
    required init(view: CoffeeListViewProtocol, networkService: NetworkServiceProtocol, router: RouterProtocol) {
        self.view = view
        self.networkService = networkService
        self.router = router
        super.init()
        Task{
            await requestCoffees(str: "https://api.sampleapis.com/coffee/hot")
            await requestCoffees(str: "https://api.sampleapis.com/coffee/iced")
            if !coffeeList.isEmpty {
                view.reload()
                //collectData()
            }
        }
    }
    
    func requestCoffees(str: String) async {
        guard let urlString = str as? String else { return }
        let result = await try! self.networkService.requestCoffeeList(urlString: urlString)
        if case .failure(let error) = result {
            if error.localizedDescription == "The operation couldn’t be completed. (MoscowEvents.HTTPError error 0.)" {
                self.view?.noInternet()
            } else{
                self.view?.requestFailure(error: error)
            }
        }
        if case .success(let requestResp) = result{
            guard let resultArray = requestResp else { return }
            coffeeList.append(resultArray)
            itemsCount.append(resultArray.count)
            var imagesArray: [UIImage] = []
            for item in resultArray{
                let photo = await try! self.downloadImage(string: item.image)
                imagesArray.append(photo)
            }
            coffeeImages.append(imagesArray)
        }
    }
    
    func downloadImage(string: String) async -> UIImage {
        var finalImg: UIImage?
        guard let imageUrlString = string as? String else {
            let imageUrlString = "https://icon-library.com/images/no-image-available-icon/no-image-available-icon-7.jpg"
            return UIImage(named: "Error")!}
        let result = await self.networkService.requestImage(from: imageUrlString)
        if case .failure(let error) = result {
            guard let errorImg = UIImage(named: "Error") else { return UIImage(named: "Error")!}
            finalImg = errorImg
        }
        if case .success(let data) = result{
            let image = UIImage(data: data!)
            let errorImg = UIImage(named: "Error")!
            finalImg = image ?? errorImg
        }
        return finalImg ?? UIImage(named: "Error")!
    }
    
    func collectData() {
        for i in 0...coffeeList.count-1{
            for j in 0...coffeeList[i].count-1{
                downloadOneCoffee(coffee: coffeeList[i][j], image: coffeeImages[i][j], index: i)
            }
            downloadedCoffees.append(tempDownloaded)
            tempDownloaded = []
        }
    }
    
    func downloadOneCoffee(coffee: CoffeeModel, image: UIImage, index: Int) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Coffee", in: managedContext)!
        let newCoffee = NSManagedObject(entity: entity, insertInto: managedContext)
        let jpegImageData = image.jpegData(compressionQuality: 1.0)
        newCoffee.setValue(coffee.title, forKeyPath: "title")
        newCoffee.setValue(coffee.description, forKeyPath: "described")
        newCoffee.setValue(coffee.id, forKeyPath: "id")
        newCoffee.setValue(jpegImageData, forKeyPath: "image")
        newCoffee.setValue(index, forKeyPath: "index")
        var arrayString = ""
        for i in 0...coffee.ingredients.count-1{
            if i == coffee.ingredients.count-1{
                arrayString += coffee.ingredients[i]
            } else {
                arrayString += "\(coffee.ingredients[i]) "
            }
        }
        newCoffee.setValue(arrayString, forKeyPath: "ingredients")
        do {
            try managedContext.save()
            tempDownloaded.append(newCoffee)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func fetchCoffees() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Coffee")
        do {
            let savedData = try managedContext.fetch(fetchRequest)
            if savedData.isEmpty{
                var index = 0
                for i in 0...savedData.count-1{
                    var objectNumber = savedData[i].value(forKeyPath: "index") as! Int
                    if objectNumber == index {
                        uploadOneCoffee(coffee: savedData[i], index: objectNumber)
                    } else {
                        uploadOneCoffee(coffee: savedData[i], index: objectNumber)
                        index += 1
                    }
                }
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func uploadOneCoffee(coffee: NSManagedObject, index: Int){
        let errorImg = UIImage(named: "Error")!
        let image = UIImage(data: coffee.value(forKeyPath: "image") as! Data) ?? errorImg
        let title = coffee.value(forKeyPath: "title") as! String
        let id = coffee.value(forKeyPath: "id") as! Int
        let description = coffee.value(forKeyPath: "described") as! String
        coffeeList[index].append(CoffeeModel(title: title, description: description, ingredients: [], image: "", id: id))
        coffeeImages[index].append(image)
    }
    
    func repeatRequest() {
        Task{
            await requestCoffees(str: "https://api.sampleapis.com/coffee/hot")
            await requestCoffees(str: "https://api.sampleapis.com/coffee/iced")
            if !coffeeList.isEmpty{
                view?.reload()
                collectData()
            } else{
                if !downloadedCoffees.isEmpty {
                    fetchCoffees()
                }
            }
        }
    }
    
    func formBanners()->[UIViewController]{
        for item in bannerPhotos{
            let v = BannerView(image: item)
            var vc = UIViewController()
            vc.view = v
            banners.append(vc)
        }
        return banners
    }
    
    
}

extension CoffeeListPresenter: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return itemsCount.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemsCount[section]
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title = ""
        switch section {
        case 0:
            title = "Горячие напитки"
        case 1:
            title = "Холодные напитки"
        default:
            break
        }
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoffeeCell.reuseId, for: indexPath) as! CoffeeCell
        let title = coffeeList[indexPath.section][indexPath.row].title
        let description = coffeeList[indexPath.section][indexPath.row].description
        let image = coffeeImages[indexPath.section][indexPath.row]
        cell.configure(title: title, description: description, image: image)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 172.0
    }
}

extension CoffeeListPresenter: UITableViewDelegate{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section > 0 || indexPath.row >= 2 && !heightAdjusted{
            view?.adjustHeight()
            heightAdjusted = true
        }
        if indexPath.section == 0 && indexPath.row <= 3 && heightAdjusted{
            view?.rebuildBanners()
            heightAdjusted = false
        }
    }
}

extension CoffeeListPresenter: UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = banners.index(of: viewController) else { return nil }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else { return banners.last }
        guard banners.count > previousIndex else { return nil }
        return banners[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = banners.index(of: viewController) else { return nil }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < banners.count else { return banners.first }
        guard banners.count > nextIndex else { return nil }
        return banners[nextIndex]
    }
    
    
}

extension CoffeeListPresenter: DropDownDataSourceProtocol{
    func getDataToDropDown(cell: UITableViewCell, indexPos: Int, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
        let customCell = cell as! UITableViewCell
            customCell.textLabel?.text = self.cities[indexPos]
        }

    }
    
    func numberOfRows(makeDropDownIdentifier: String) -> Int {
        return self.cities.count
    }
    
    func selectItemInDropDown(indexPos: Int, makeDropDownIdentifier: String) {
        view?.changeCity(city: cities[indexPos])
    }
}
