//
//  weatherData.swift
//  mapApp
//
//  Created by Woojeh Chung on 4/22/23.
//

import Foundation

struct WeatherAPIResponse: Decodable {
    let current: CurrentWeather
}

struct CurrentWeather: Decodable {
    let temp_f: Double
    let condition: Condition
    let wind_mph: Double
    let wind_degree: Int
    let wind_dir: String
    let humidity: Int
    let cloud: Int
    let feelslike_f: Double
    let uv: Double
}

struct Condition: Decodable {
    let text: String
    let icon: String
}
