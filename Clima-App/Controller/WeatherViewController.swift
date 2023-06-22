import UIKit
import SnapKit
import CoreLocation

class WeatherViewController: UIViewController {
    var weatherManeger = WeatherManager()
    let locationManager = CLLocationManager()
    private let background: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private let topStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 10
        return stackView
    }()
    private let locationButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "location.circle.fill2"), for: .normal)
        button.setImage(UIImage(named: "location.circle.Highlighted"), for: .highlighted)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    private let searchTextField: UITextField = {
       let textField = UITextField()
        textField.placeholder = "search"
        textField.textAlignment = .right
        textField.backgroundColor = .systemFill
        textField.textColor = .label
        textField.font = .systemFont(ofSize: 25)
        textField.borderStyle = .roundedRect
        return textField
    }()
    private let searchButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "magnifyingglass"), for: .normal)
        button.setImage(UIImage(named: "buttonImageHighlighted"), for: .highlighted)
        button.imageView?.contentMode = .scaleAspectFill
        return button
    }()
    private let conditionImage: UIImageView = {
       let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.max")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(named: "weather")
        return imageView
    }()
    private let tempStackView: UIStackView = {
       let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 80, weight: .black)
        label.textAlignment = .right
        label.textColor = .label
        return label
    }()
    private let endTemperature: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 100, weight: .light)
        label.textAlignment = .right
        label.textColor = .label
        label.text = "°C"
        return label
    }()
    private let cityLabel: UILabel = {
       let label = UILabel()
        label.font = .systemFont(ofSize: 30)
        label.textAlignment = .right
        label.textColor = .label
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
        setup()
    }
    
    func setup() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        searchTextField.delegate = self
        weatherManeger.delegate = self
        locationButton.addTarget(self, action: #selector(locationPressed), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchPressed), for: .touchUpInside)
    }
    func style() {
        view.addSubview(background)
        view.addSubview(topStackView)
        topStackView.addArrangedSubview(locationButton)
        topStackView.addArrangedSubview(searchTextField)
        topStackView.addArrangedSubview(searchButton)
        view.addSubview(conditionImage)
        view.addSubview(tempStackView)
        tempStackView.addArrangedSubview(temperatureLabel)
        tempStackView.addArrangedSubview(endTemperature)
        view.addSubview(cityLabel)
    }
    func layout() {
        background.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalToSuperview()
        }
        topStackView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
        locationButton.snp.makeConstraints { make in
            make.height.width.equalTo(35)
        }
        searchButton.snp.makeConstraints { make in
            make.height.width.equalTo(35)
        }
        conditionImage.snp.makeConstraints { make in
            make.top.equalTo(topStackView.snp.bottom).offset(15)
            make.trailing.equalToSuperview().offset(-10)
            make.height.width.equalTo(120)
        }
        tempStackView.snp.makeConstraints { make in
            make.top.equalTo(conditionImage.snp.bottom).offset(10)
            make.trailing.equalToSuperview().offset(-10)
        }
        cityLabel.snp.makeConstraints { make in
            make.top.equalTo(tempStackView.snp.bottom)
            make.trailing.equalToSuperview().offset(-10)
        }
    }

    @objc func locationPressed() {
        locationManager.requestLocation()
    }
    @objc func searchPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
}

extension WeatherViewController: UITextFieldDelegate {
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
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.tempratureString
            self.conditionImage.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    func didFailError(error: Error) {
        DispatchQueue.main.async {
            self.cityLabel.text = error.localizedDescription
        }
    }
}
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
            self.cityLabel.text = error.localizedDescription
    }
}
