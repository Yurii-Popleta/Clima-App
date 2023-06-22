
import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
    let wind: Wind
}
struct Weather: Codable {
    let id: Int
}
struct Main: Codable {
    let temp: Double
}
struct Wind: Codable {
    let speed: Float
}
