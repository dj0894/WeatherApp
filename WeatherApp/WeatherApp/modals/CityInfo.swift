//
//  CityInfo.swift
//  WeatherApp
//
//  Created by Deepika Jha on 29/10/21.
//

import Foundation
import RealmSwift

class CityInfo : Object {
    @objc dynamic var key: String  = ""
    @objc dynamic var type : String = ""
    @objc dynamic  var localizedName : String = ""
    @objc dynamic var countryId : String = ""
    @objc dynamic var administrativeId : String = ""

    
    override static func primaryKey() -> String? {
        return "key"
    }
    
}
