//
//  Weather.swift
//  WeatherMood
//
//  Created by Benjamin Simpson on 6/5/20.
//  Copyright © 2020 Benjamin Simpson. All rights reserved.
//

import Foundation

public struct Weather: Decodable {
    let description: String?
    let id: Int?
}

public struct WeatherData: Decodable {
    let name: String?
    let main: Main?
    let weather: [Weather]
}

public struct WeatherModel {
    let cityName: String
    let conditionId: Int
    let temperature: Double
    
    var temperatureCall: String{
        return String(format: "%.1f", temperature)
    }
}

public struct Main: Decodable {
    let temp: Double?
}


