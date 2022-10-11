
import Foundation
import CoreLocation

//MARK: - Here we create a protocol for delegate to send data from this file to WeatherViewController.

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailError(error: Error)
    }

struct WeatherManager {
    
    //MARK: - This is url for weather that we use in fuction fetchWeather.
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=d3c125ddb671b1917771cd0e91ff521c&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
//MARK: - Here we create a whole url by adding to url a city name or latitude and longitude that we take from WeatherViewController, and we use this whole url in func performRequest.
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }

    //MARK: - In this fuction we create a url session, take data and put this data in JSON format in func parseJSON, also this func parseJSON have a output, so we put data from this func parseJSON into delegate func didUpdateWeather.

    func performRequest(with urlString: String) {
        
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFailError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            
            task.resume()
        }
    }
    
    //MARK: - In this func we grab the data from func performRequest in format JSON and decoding this data into struct WeatherData, and after this we put this data from struct WeatherData into struct WeatherModel and after this we put this initial struct WeatherModel in output this function parseJSON.
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        
      let decoder = JSONDecoder()
      do {
        let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
       
        let id = decodedData.weather[0].id
        let temp = decodedData.main.temp
        let name = decodedData.name
          
        let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
        return weather
          
      } catch {
          delegate?.didFailError(error: error)
          return nil
      }
    }
 
}
    



