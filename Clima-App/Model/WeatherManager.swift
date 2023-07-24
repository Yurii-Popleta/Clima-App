import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailError(error: Error)
}

struct WeatherManager {
    private let weatherURL = "https://api.openweathermap.org/data/2.5/weather?&appid=d3c125ddb671b1917771cd0e91ff521c&units=metric"
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    func performRequest(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                self.delegate?.didFailError(error: error)
                return
            } else if let data, let weather = self.parseJSON(data) {
                self.delegate?.didUpdateWeather(self, weather: weather)
            }
        }.resume()
    }
    func parseJSON(_ jsonData: Data)->WeatherModel? {
       do { let decoder = JSONDecoder()
            let decodedData = try decoder.decode(WeatherData.self, from: jsonData)
            let weather = WeatherModel(conditionId: decodedData.weather[0].id, cityName: decodedData.name, temperature: decodedData.main.temp)
            return weather
        } catch {
            delegate?.didFailError(error: error)
            return nil
        }
    }
}
