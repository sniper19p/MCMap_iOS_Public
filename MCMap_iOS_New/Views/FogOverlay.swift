import SwiftUI
import MapKit

struct FogOverlay: View {
    let userLocation: CLLocationCoordinate2D?
    let visibleRadius: Double // Radius in meters
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Create a path for the entire screen
                let background = Path(CGRect(origin: .zero, size: size))
                
                // Calculate center point (middle of the screen)
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                
                // Fill the entire screen with a semi-transparent black
                context.fill(background, with: .color(.black.opacity(0.5)))
                
                // Create a circular path for the visible area
                let visibleArea = Path { path in
                    let radius = size.width / 4 // Using 1/4 of screen width as radius for now
                    path.addArc(center: center, radius: radius, startAngle: .zero, endAngle: .degrees(360), clockwise: false)
                }
                
                // Use blending to create a "hole" in the fog
                context.blendMode = .destinationOut
                context.fill(visibleArea, with: .color(.white))
            }
        }
        .allowsHitTesting(false) // Allow interaction with the map underneath
    }
}

#Preview {
    FogOverlay(userLocation: CLLocationCoordinate2D(latitude: 37.3346, longitude: -122.0090), visibleRadius: 100)
        .frame(width: 400, height: 400)
        .background(Color.blue) // For preview only
}
