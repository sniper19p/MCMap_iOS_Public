import SwiftUI
import MapKit
import CoreLocation

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var userLocation: CLLocationCoordinate2D?
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

class MapViewModel: ObservableObject {
    @Published var mapView: MKMapView?
    @Published var mapProxy: MapProxy?
    
    func setupMapView(_ view: MKMapView) {
        self.mapView = view
        self.mapProxy = MapProxy(mapView: view)
    }
}

struct MapView: View {
    @StateObject private var locationViewModel = LocationViewModel()
    @StateObject private var mapViewModel = MapViewModel()
    @StateObject private var exploredManager = ExploredAreaManager()
    @State private var visibleRadius: Double = 200 // 200 meters visible radius
    
    // Timer to update explored areas
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            MapViewRepresentable(mapViewModel: mapViewModel)
            
            if let location = locationViewModel.userLocation {
                // Add a circular overlay at user's location
                Circle()
                    .stroke(Color.blue.opacity(0.5), lineWidth: 2)
                    .background(Circle().fill(Color.blue.opacity(0.2)))
                    .frame(width: 40, height: 40)
                    .position(
                        x: mapViewModel.mapProxy?.convert(location, to: .global).x ?? 0,
                        y: mapViewModel.mapProxy?.convert(location, to: .global).y ?? 0
                    )
            }
            
            MinecraftFogOverlay(exploredManager: exploredManager, mapProxy: mapViewModel.mapProxy)
        }
        .onReceive(timer) { _ in
            if let location = locationViewModel.userLocation {
                // Add multiple terrain points around the user's location
                for dx in [-0.0001, 0, 0.0001] {
                    for dy in [-0.0001, 0, 0.0001] {
                        let newLat = location.latitude + dx
                        let newLng = location.longitude + dy
                        exploredManager.addExploredArea(
                            CLLocationCoordinate2D(latitude: newLat, longitude: newLng),
                            mapProxy: mapViewModel.mapProxy
                        )
                    }
                }
            }
        }
        .ignoresSafeArea()
        .overlay(
            VStack {
                if locationViewModel.userLocation == nil {
                    Text("Waiting for location...")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                Spacer()
                
                // Visibility radius slider
                HStack {
                    Text("Visibility: \(Int(visibleRadius))m")
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    Slider(value: $visibleRadius, in: 50...500)
                        .padding(.horizontal)
                }
                .background(Color.black.opacity(0.7))
                .cornerRadius(10)
                .padding()
            }
        )
    }
}

struct MapViewRepresentable: UIViewRepresentable {
    @ObservedObject var mapViewModel: MapViewModel
    
    func makeUIView(context: Context) -> MKMapView {
        let view = MKMapView()
        view.showsUserLocation = true
        view.userTrackingMode = .follow
        DispatchQueue.main.async {
            mapViewModel.setupMapView(view)
        }
        return view
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update view if needed
    }
}
