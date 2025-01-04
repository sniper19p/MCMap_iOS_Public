import Foundation
import CoreLocation
import MapKit

class ExploredAreaManager: ObservableObject {
    @Published var exploredAreas: [ExploredArea] = []
    private let gridSize: Double = 50 // Size of each grid cell in meters
    
    struct ExploredArea: Identifiable, Hashable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let timestamp: Date
        let terrainType: TerrainType
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: ExploredArea, rhs: ExploredArea) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    func addExploredArea(_ coordinate: CLLocationCoordinate2D, mapProxy: MapProxy?) {
        // Snap to grid
        let lat = round(coordinate.latitude * 10000) / 10000
        let lon = round(coordinate.longitude * 10000) / 10000
        let snappedCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
        // Determine terrain type
        let terrain = TerrainType.classify(coordinate: snappedCoordinate, mapProxy: mapProxy)
        
        let newArea = ExploredArea(
            coordinate: snappedCoordinate,
            timestamp: Date(),
            terrainType: terrain
        )
        
        // Check if area is already explored
        if !exploredAreas.contains(where: { area in
            let distance = MKMapPoint(area.coordinate).distance(to: MKMapPoint(newArea.coordinate))
            return distance < gridSize
        }) {
            DispatchQueue.main.async {
                self.exploredAreas.append(newArea)
            }
        }
    }
    
    func isExplored(coordinate: CLLocationCoordinate2D) -> Bool {
        exploredAreas.contains { area in
            let distance = MKMapPoint(area.coordinate).distance(to: MKMapPoint(coordinate))
            return distance < gridSize
        }
    }
}
