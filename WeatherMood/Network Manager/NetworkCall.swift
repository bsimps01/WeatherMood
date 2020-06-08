//
//  Network.swift
//  WeatherMood
//
//  Created by Benjamin Simpson on 6/5/20.
//  Copyright © 2020 Benjamin Simpson. All rights reserved.
//

import Foundation


class NetworkCall {
    
    let baseURL = "http://api.openweathermap.org/data/2.5/"
    let apiKey = secretKey
    let urlSession = URLSession.shared
    
    public static let shared = NetworkCall()
    
    enum networkCalls {
        case currentWeather(q: String)
        
        func getHTTPMethod() -> String {
            return "GET"
        }
        
        func getPath() -> String {
             switch self {
             case .currentWeather:
                return "weather"
             }
        }
        func getHeaders(secretKey: String) -> [String: String] {
                return [
                    "Accept": "application/json",
                    "Content-Type": "application/json",
                    "Authorization": "X-Api-Key \(secretKey)",
                    "Host": "api.openweathermap.org"
                ]
            }
            
        func catchParameters() -> [String:String] {
            switch self {
            case .currentWeather(let city):
                return ["q": city,
                        "units": "imperial",
                        "appid": secretKey
                        ]
            }
            
        }
        func parametersToString() -> String {
                let parameterArray = catchParameters().map { key, value in
                    return "\(key)=\(value)"
                }
                return parameterArray.joined(separator: "&")
            }
        }
        enum Result<T> {
             case success(T)
             case failure(Error)
         }
         
         enum networkError: Error {
             case couldNotParse
             case noData
         }
    
    private func weatherRequest(for networkCall: networkCalls) -> URLRequest {
        
        let stringParams = networkCall.parametersToString()
        let path = networkCall.getPath()
        let fullURL = URL(string: baseURL.appending("\(path)?\(stringParams)"))!
    
        var request = URLRequest(url: fullURL)
        request.httpMethod = networkCall.getHTTPMethod()
        request.allHTTPHeaderFields = networkCall.getHeaders(secretKey: "\(apiKey)")
        print("\(String(describing: request.allHTTPHeaderFields))")
        return request
    }
    
    func getWeatherData(cityName: String, _ completion: @escaping (Result<[WeatherData]>) -> Void) {
        let tempRequest = weatherRequest(for: .currentWeather(q: cityName))
        
        let task = urlSession.dataTask(with: tempRequest) { data, response, error in
            // Check for errors.
            if let error = error {
                return completion(Result.failure(error))
            }
            
            guard let data = data else {
                return completion(Result.failure(networkError.noData))
            }
            
            do{
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                print(jsonObject)
            } catch {
                print(error.localizedDescription)
            }
            guard let result = try? JSONDecoder().decode(WeatherData.self, from: data) else {
                
                return completion(Result.failure(networkError.couldNotParse))
            }
            
            let cityName = result.self
            
            // Return the result with the completion handler.
            DispatchQueue.main.async {
                completion(Result.success(cityName))
            }
        }
        
        task.resume()
    }
}
