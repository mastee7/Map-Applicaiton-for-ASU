//
//  weatherAPI.swift
//  mapApp
//
//  Created by Woojeh Chung on 4/22/23.
//

import Foundation
import Combine

class WeatherAPI: ObservableObject {
    private let baseURL = "http://api.weatherapi.com/v1/current.json?key=5801ee6c650c432a95a235237232104&q="
    private var cancellable: AnyCancellable?

    @Published var currentWeather: CurrentWeather?

    func fetchWeatherData(latitude: String, longitude: String) {
        let url = "\(baseURL)\(latitude),\(longitude)&aqi=no"
        guard let apiUrl = URL(string: url) else { return }

        cancellable = URLSession.shared.dataTaskPublisher(for: apiUrl)
            .map { $0.data }
            .decode(type: WeatherAPIResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching weather data: \(error)")
                }
            }, receiveValue: { [weak self] weatherAPIResponse in
                self?.currentWeather = weatherAPIResponse.current
            })
    }
}

