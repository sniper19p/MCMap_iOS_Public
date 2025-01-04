import SwiftUI
import MapKit

struct MinecraftFogOverlay: View {
    @ObservedObject var exploredManager: ExploredAreaManager
    let mapProxy: MapProxy?
    
    // Minecraft-inspired colors
    private let fogColor = Color(red: 0.1, green: 0.1, blue: 0.15)
    private let gridColor = Color(red: 0.2, green: 0.2, blue: 0.25)
    
    private func terrainColor(_ type: TerrainType) -> Color {
        let (r, g, b) = type.color
        return Color(red: Double(r), green: Double(g), blue: Double(b))
    }
    
    private func drawTree(in context: GraphicsContext, at point: CGPoint, size: CGFloat) {
        // Tree trunk
        let trunkRect = CGRect(
            x: point.x - size/6,
            y: point.y + size/3,
            width: size/3,
            height: size/3
        )
        context.fill(
            Path(trunkRect),
            with: .color(Color(red: 0.4, green: 0.26, blue: 0.13))
        )
        
        // Tree leaves
        let leavesRect = CGRect(
            x: point.x - size/2,
            y: point.y - size/2,
            width: size,
            height: size
        )
        context.fill(
            Path(leavesRect),
            with: .color(terrainColor(.tree))
        )
    }
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                // Draw base fog
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(fogColor.opacity(0.7)))
                
                // Draw grid pattern
                let gridSize: CGFloat = 20
                for x in stride(from: 0, to: size.width, by: gridSize) {
                    for y in stride(from: 0, to: size.height, by: gridSize) {
                        let rect = CGRect(x: x, y: y, width: gridSize, height: gridSize)
                        context.stroke(Path(rect), with: .color(gridColor.opacity(0.3)), lineWidth: 1)
                    }
                }
                
                // Draw explored areas with terrain
                for area in exploredManager.exploredAreas {
                    if let point = mapProxy?.convert(area.coordinate, to: .global) {
                        let tileSize: CGFloat = 40
                        let rect = CGRect(
                            x: point.x - tileSize/2,
                            y: point.y - tileSize/2,
                            width: tileSize,
                            height: tileSize
                        )
                        
                        // Draw base terrain
                        let baseColor = terrainColor(area.terrainType)
                        context.fill(Path(rect), with: .color(baseColor.opacity(0.8)))
                        
                        // Add pixelated border
                        context.stroke(Path(rect), with: .color(.black.opacity(0.2)), lineWidth: 2)
                        
                        // Add terrain-specific details
                        switch area.terrainType {
                        case .water, .deepWater:
                            // Add wave pattern
                            for i in 0...2 {
                                let waveRect = CGRect(
                                    x: rect.minX,
                                    y: rect.minY + CGFloat(i) * tileSize/3,
                                    width: tileSize,
                                    height: 2
                                )
                                context.fill(
                                    Path(waveRect),
                                    with: .color(Color.white.opacity(0.2))
                                )
                            }
                            
                        case .grass:
                            // Add grass tufts
                            for _ in 0...3 {
                                let x = rect.minX + .random(in: 0...tileSize)
                                let y = rect.minY + .random(in: 0...tileSize)
                                let tuftPath = Path { path in
                                    path.move(to: CGPoint(x: x, y: y))
                                    path.addLine(to: CGPoint(x: x + 2, y: y - 4))
                                }
                                context.stroke(tuftPath, with: .color(Color.green.opacity(0.6)), lineWidth: 2)
                            }
                            
                        case .tree:
                            drawTree(in: context, at: point, size: tileSize)
                            
                        case .sand:
                            // Add sand texture
                            for _ in 0...5 {
                                let dotRect = CGRect(
                                    x: rect.minX + .random(in: 0...tileSize),
                                    y: rect.minY + .random(in: 0...tileSize),
                                    width: 2,
                                    height: 2
                                )
                                context.fill(
                                    Path(dotRect),
                                    with: .color(Color.white.opacity(0.3))
                                )
                            }
                            
                        case .stone:
                            // Add stone cracks
                            for _ in 0...2 {
                                let start = CGPoint(
                                    x: rect.minX + .random(in: 0...tileSize),
                                    y: rect.minY + .random(in: 0...tileSize)
                                )
                                let end = CGPoint(
                                    x: start.x + .random(in: -5...5),
                                    y: start.y + .random(in: -5...5)
                                )
                                let crackPath = Path { path in
                                    path.move(to: start)
                                    path.addLine(to: end)
                                }
                                context.stroke(crackPath, with: .color(Color.black.opacity(0.3)), lineWidth: 1)
                            }
                        }
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}

extension Color {
    func adjustBrightness(by amount: CGFloat) -> Color {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        return Color(hue: Double(hue),
                    saturation: Double(saturation),
                    brightness: Double(max(0, min(1, brightness + amount))),
                    opacity: Double(alpha))
    }
}

#Preview {
    MinecraftFogOverlay(exploredManager: ExploredAreaManager(), mapProxy: nil)
        .frame(width: 400, height: 400)
        .background(Color.blue)
}
