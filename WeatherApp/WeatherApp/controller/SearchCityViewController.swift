//
//  SearchCityViewController.swift
//  WeatherApp
//
//  Created by Deepika Jha on 28/10/21.
//

import UIKit
import Alamofire
import SwiftSpinner
import SwiftyJSON
import PromiseKit
import RealmSwift

class SearchCityViewController: UIViewController,UISearchBarDelegate,UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tblVIew: UITableView!
    
    var arrCityInfo : [CityInfo] = [CityInfo]()
    var tableCellInfo: [String] = []
    
    let arr=["abc","def","edf"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return arrCityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let len=arrCityInfo.count
        tableCellInfo = []
        for i in 0...(len-1){
            let city=arrCityInfo[i];
            let tableCellData=("\(city["localizedName"]!) \(city["administrativeId"]!) \(city["countryId"]!)")
            tableCellInfo.append(tableCellData)
        }
        cell.textLabel?.text=tableCellInfo[indexPath.row]
        return cell
    }
    
    //Create location Search Url
    func getSearchURL(_ searchText : String) -> String {
        let urlEncodedSearchText = searchText.addingPercentEncoding(withAllowedCharacters: .alphanumerics)
        return locationSearchURL + "apikey=" + apiKey + "&q=" + urlEncodedSearchText!
    }
    
    //Search for cities when search bar is populated with city initials like Sea
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if(searchText.count<3){
            return
        }
        getCitiesFromSearch(searchText)
    }
    
    
    //getCitiesFromSearch
    func getCitiesFromSearch(_ searchText:String){
        //Network call from there
        // Receive JSON array
        // Parse the JSON array
        // Add values in arrCityInfo
        // Reload table with the values
        let url = getSearchURL(searchText)
        AF.request(url).responseJSON { response in
            if response.error != nil {
                print(response.error?.localizedDescription)
                return
            }
            
            let cities=JSON(response.data!).array
            if (cities == nil) {
                return
            }
            if(cities?.isEmpty==true){
                return
            }
            
            
            self.arrCityInfo = [CityInfo]()
            
            for city in cities!{
                let cityInfo=CityInfo()
                cityInfo.key=city["Key"].stringValue
                cityInfo.type=city["Type"].stringValue
                cityInfo.localizedName = city["LocalizedName"].stringValue
                cityInfo.countryId=city["Country"]["ID"].stringValue
                cityInfo.administrativeId=city["AdministrativeArea"]["ID"].stringValue
                //appending cityInfo object to array arrCityInfo
                self.arrCityInfo.append(cityInfo)
            }
            
            self.tblVIew.reloadData()
            
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // You will get the Index of the city info from here and then add it into the realm Database
        // Once the city is added in the realm DB pop the navigation view controller
        let selectedItem=arrCityInfo[indexPath.row]
        let cityKey: String = selectedItem["key"] as! String
        if(checkIfCityExistInDB(cityKey)==false){
            print("adding city in db")
            addCityInfoInDB(selectedItem)
        } else {
            print("city already exist in db")
        }
        
    }
    
    func addCityInfoInDB(_ cityInfo:CityInfo)->Bool{
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        do{
            let realm=try Realm();
            try realm.write{
                realm.add(cityInfo, update: .modified)
            }
        }catch{
            print("error from db\(error)")
        }
        return true;
    }
    
    func deletedObjectsFromRealmDb(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func checkIfCityExistInDB(_ key:String)->Bool{
        do{
            let realm=try Realm();
            if realm.object(ofType: CityInfo.self, forPrimaryKey: key) != nil {
                return true
            }
        }catch{
            print("error from db\(error)")
        }
        
        return false
    }
    
    
    
}

