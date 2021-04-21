//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateValue(value: String, currencyName: String)
    func didFailWithError(error: Error?)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC/"
    let apiKey = "9B9155A9-E18D-475D-B7BD-42C2FFDCA8DC"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","INR","JPY","MXN","NOK","NZD","PHP" ,"PLN","RUB","SGD","USD","ZAR"]
    
    var delegate : CoinManagerDelegate?

    func getCoinPrice(for currency: String) {
        let urlString = baseURL + currency + "?apikey=" + apiKey
        performRequest(with: urlString, currency: currency)
    }
    
    func convertDoubleToString(_ value: Double) -> String {
        let stringValue = String(round(value*100) / 100)
        return stringValue
    }
    
    func performRequest(with urlString: String, currency: String) {
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            
            //get specific weather data from JSON
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                
                if let safeData = data {
                    let value = self.parseJSON(from: safeData)
                    if value > 0.0 {
                        self.delegate?.didUpdateValue(value: convertDoubleToString(value), currencyName: currency)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    func parseJSON(from data: Data) -> Double {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            return decodedData.rate
        } catch {
            delegate?.didFailWithError(error: error)
            return 0.0
        }
    }
}
