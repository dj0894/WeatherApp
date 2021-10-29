//
//  ViewController.swift
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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tblView: UITableView!
    
    let arr1=["02","02","03"]
    
    let arr = ["Seattle WA, USA 54 °F", "Delhi DL, India, 75°F"]
    var arrCityInfo: [CityInfo] = [CityInfo]()
    var arrCurrentWeather : [CurrentWeather] = [CurrentWeather]()
    var tableCellInfo: [String] = []
    var imageIcons: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblView.dataSource=self
        tblView.delegate=self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadCurrentConditions()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCurrentWeather.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

    //   let cell=tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cell=Bundle.main.loadNibNamed("customTableViewCell", owner:self, options:nil)?.first as! customTableViewCell
       
        
        let len=arrCurrentWeather.count
        
        tableCellInfo = []
        imageIcons=[]
        for i in 0...(len-1){
            let cityWeather=arrCurrentWeather[i];
            print(cityWeather)
            print(type(of: cityWeather))
            var tableCellData=("\(cityWeather.cityInfoName) | \(cityWeather.weatherText) | \(cityWeather.celcius)°C |")

            tableCellInfo.append(tableCellData)
            imageIcons.append("\(cityWeather.weatherIcon)")
        }
        print(tableCellInfo)
        print(imageIcons)
//        cell.textLabel?.text=tableCellInfo[indexPath.row]
        cell.imageLabel.text=tableCellInfo[indexPath.row]
        cell.imgView?.image=UIImage(named: imageIcons[indexPath.row])
        
        return cell
    }
    
    
    func loadCurrentConditions(){
       // print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // Read all the values from realm DB and fill up the arrCityInfo
        // for each city info het the city key and make a NW call to current weather condition
        // wait for all the promises to be fulfilled
        // Once all the promises are fulfilled fill the arrCurrentWeather array
        // call for reload of tableView
        
        let realm = try! Realm()
        let dataFromDB=realm.objects(CityInfo.self)
        let dataFromDBLen=dataFromDB.count
        if(dataFromDBLen==0){
            print("No data in database")
            return
        }
        //Adding CityInfo from realmDB to arrCityInfo array
        arrCityInfo = [CityInfo]()
        for i in 0...(dataFromDBLen-1){
            arrCityInfo.append(dataFromDB[i])
        }
        
        //Doing networking call for each city from arrCityInfo
        getCurrentWeatherCondition(arrCityInfo);
        
    }
    
    
    func getCurrentWeatherCondition(_ arrCityInfo:[CityInfo]){
        //array to append the current weather or city
        self.arrCurrentWeather = [CurrentWeather]()
        
        for i in 0...(arrCityInfo.count-1){
            let city=arrCityInfo[i];
            let key=city["key"] as! String
            let cityName=city["localizedName"]!
            let url=currentConditionURL+key as! String+"?apikey="+apiKey
            
            print(url)
            AF.request(url).responseJSON { response in
                if response.error != nil {
                    print(response.error?.localizedDescription)
                    return
                }
                let cityCurrentCondition=JSON(response.data!).array
                print(response.data!)
                if(cityCurrentCondition==nil){
                    print("cityCurrentCondition is nil")
                    return
                }
                
                if(cityCurrentCondition?.isEmpty==true){
                    print("Invalid key or issue with url")
                    return
                }
                
                for weather in cityCurrentCondition!{
                    //create object of currentWeather Modal
                    let  currentWeather=CurrentWeather();
                    currentWeather.cityKey=key as! String
                    currentWeather.cityInfoName=cityName as! String
                    currentWeather.weatherText=weather["WeatherText"].stringValue
                    currentWeather.epochTime=weather["EpochTime"].intValue
                    currentWeather.isDayTime=weather["IsDayTime"].boolValue
                    currentWeather.celcius=weather["Temperature"]["Metric"]["Value"].intValue
                    currentWeather.fahreneit=weather["Temperature"]["Imperial"]["Value"].intValue
                    currentWeather.weatherIcon=weather["WeatherIcon"].intValue
                    self.arrCurrentWeather.append(currentWeather)
                }
                //reload tableView data
                self.tblView.reloadData()
                
            }
            
        }
    }
    
    func deletedObjectsFromRealmDb(){
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    
}

