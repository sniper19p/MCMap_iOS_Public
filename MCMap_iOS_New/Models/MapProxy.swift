import Foundation
import MapKit
import CoreLocation

class MapProxy {
    private let mapView: MKMapView
    
    init(mapView: MKMapView) {
        self.mapView = mapView
    }
    
    func convert(_ coordinate: CLLocationCoordinate2D, to space: MapSpace) -> CGPoint {
        switch space {
        case .global:
            return mapView.convert(coordinate, toPointTo: nil)
        }
    }
}

enum MapSpace {
    case global
}
