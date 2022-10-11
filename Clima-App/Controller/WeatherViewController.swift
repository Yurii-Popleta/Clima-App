import UIKit
import CoreLocation

class WeatherViewController: UIViewController {
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    var  weatherManeger = WeatherManager()
    let locationManager = CLLocationManager()
    
    //MARK: - In ViewDidLoad we set the WeatherViewController as delegete to searchTextField, weatherManeger, locationManager and also we ask user to use hes location and then do the request location.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        searchTextField.delegate = self
        weatherManeger.delegate = self
    }
    
    //MARK: - Here we do the request location when user tap this button.
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
}

//MARK: - Here we use some UITextFieldDelegate, we check when user tap actual button we close TextField, also close TextField when user tap return button on TextField, also we check when user can close TextField, and also send to the weatherManeger struct name of the city, that user wrote when TextField actually closed.

extension WeatherViewController: UITextFieldDelegate {
    
    @IBAction func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != ""{
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let cityName = searchTextField.text {
            weatherManeger.fetchWeather(cityName: cityName)
        }
        searchTextField.text = ""
    }
}

//MARK: - Here we use WeatherManagerDelegate protocol that we create in WeatherManager file, and use two function from this protocol and in fuction didUpdateWeather we use input "weather" to chanche the data on screen.

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.tempratureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    
    func didFailError(error: Error) {
        print(error)
    }
    
}

//MARK: - Here we use CLLocationManagerDelegate protocol and in fuction "didUpdateLocations" from this  delegate protocol we use input "locations" to grab actual data about location its latitude and longitude, and then we put this data into function "fetchWeather" from structure "WeatherManeger" to run a request.

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManeger.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}
