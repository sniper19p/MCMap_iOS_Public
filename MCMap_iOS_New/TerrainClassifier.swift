import Foundation
import MapKit
import CoreLocation

enum TerrainType: String {
    case grass = "mc_grass"
    case water = "mc_water"
    case sand = "mc_sand"
    case stone = "mc_stone"
    case deepWater = "mc_deep_water"
    case tree = "mc_tree"
    
    var color: (CGFloat, CGFloat, CGFloat) {
        switch self {
        case .grass:
            return (108/255, 152/255, 47/255)  // Minecraft grass green
        case .water:
            return (64/255, 63/255, 252/255)   // Minecraft water blue
        case .sand:
            return (205/255, 127/255, 55/255)  // Minecraft sand brown
        case .stone:
            return (128/255, 128/255, 128/255) // Minecraft stone gray
        case .deepWater:
            return (0/255, 0/255, 139/255)     // Deep water blue
        case .tree:
            return (34/255, 85/255, 34/255)    // Dark green for trees
        }
    }
    
    static func classify(coordinate: CLLocationCoordinate2D, mapProxy: MapProxy?) -> TerrainType {
        // For now, we'll use a deterministic but pseudo-random approach based on coordinates
        let lat = coordinate.latitude
        let lng = coordinate.longitude
        
        // Use the decimal parts of coordinates for variation
        let latDecimal = abs(lat.truncatingRemainder(dividingBy: 1))
        let lngDecimal = abs(lng.truncatingRemainder(dividingBy: 1))
        
        // Create a value between 0 and 1 based on coordinates
        let randomValue = (sin(lat * lng) + 1) / 2
        
        // Create patterns for different terrain types
        if latDecimal < 0.3 && lngDecimal < 0.3 {
            return randomValue < 0.7 ? .water : .deepWater
        } else if latDecimal > 0.7 && lngDecimal > 0.7 {
            return .sand
        } else if randomValue < 0.1 {
            return .stone
        } else if randomValue < 0.3 {
            return .tree
        } else {
            return .grass
        }
    }
}
