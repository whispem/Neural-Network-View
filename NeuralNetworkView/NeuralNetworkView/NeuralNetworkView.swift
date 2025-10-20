//
//  NeuralNetworkView.swift
//  NeuralNetworkView
//
//  Created by Emilie on 19/10/2025.
//
import SwiftUI

struct NeuralNetworkView: View {
    @State private var signals: [Signal] = []
    @State private var nodeStates: [[NodeState]] = []
    @State private var pulseAnimation: CGFloat = 0
    @State private var globalEnergy: CGFloat = 0
    @State private var totalProcessed: Int = 0
    @State private var dataFlow: CGFloat = 0
    @State private var networkAccuracy: CGFloat = 0
    @State private var processingSpeed: CGFloat = 0
    @State private var showPerformanceMetrics: Bool = true
    @State private var timeElapsed: TimeInterval = 0
    
    let networkConfig = NetworkConfig(
        layers: [6, 10, 8, 10, 6, 4],
        signalSpeed: 0.014,
        signalSpawnRate: 0.45,
        maxActiveSignals: 18
    )
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AdvancedBackground(energy: globalEnergy, dataFlow: dataFlow)
                Canvas { context, size in
                    let positions = calculateNodePositions(size: size)
                    drawQuantumConnections(context: context, positions: positions)
                    drawPremiumSignals(context: context, positions: positions, size: size)
                    drawUltraNodes(context: context, positions: positions)
                    drawNetworkMetrics(context: context, size: size)
                }
                VStack {
                    HStack {
                        StatusBadge(
                            icon: "brain.head.profile",
                            label: "Deep Learning",
                            status: "Active",
                            color: .green
                        )
                        Spacer()
                        StatusBadge(
                            icon: "waveform.path.ecg",
                            label: "Neural Activity",
                            status: String(format: "%.0f%%", globalEnergy * 100),
                            color: .cyan
                        )
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 50)
                    
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                showPerformanceMetrics.toggle()
                            }
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: showPerformanceMetrics ? "eye.slash.fill" : "chart.bar.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                Text(showPerformanceMetrics ? "Hide Metrics" : "Show Metrics")
                                    .font(.system(size: 11, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.cyan.opacity(0.4), lineWidth: 1)
                                    )
                            )
                            .shadow(color: .cyan.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                    }
                    .padding(.bottom, 12)
                    if showPerformanceMetrics {
                        VStack(spacing: 12) {
                            HStack(spacing: 16) {
                                MetricCard(
                                    title: "Active Signals",
                                    value: "\(signals.filter { $0.isActive }.count)",
                                    subtitle: "processing",
                                    icon: "arrow.triangle.branch",
                                    color: .cyan,
                                    trend: .stable
                                )
                                
                                MetricCard(
                                    title: "Network Energy",
                                    value: String(format: "%.1f%%", globalEnergy * 100),
                                    subtitle: "utilization",
                                    icon: "bolt.fill",
                                    color: .purple,
                                    trend: globalEnergy > 0.7 ? .up : .stable
                                )
                            }
                            
                            HStack(spacing: 16) {
                                MetricCard(
                                    title: "Data Processed",
                                    value: "\(totalProcessed)",
                                    subtitle: "samples",
                                    icon: "cpu",
                                    color: .blue,
                                    trend: .up
                                )
                                
                                MetricCard(
                                    title: "Model Accuracy",
                                    value: String(format: "%.1f%%", networkAccuracy),
                                    subtitle: "confidence",
                                    icon: "checkmark.seal.fill",
                                    color: .green,
                                    trend: networkAccuracy > 95 ? .up : .stable
                                )
                            }
                            
                            HStack(spacing: 16) {
                                MetricCard(
                                    title: "Processing Speed",
                                    value: String(format: "%.0f", processingSpeed),
                                    subtitle: "ops/sec",
                                    icon: "speedometer",
                                    color: .orange,
                                    trend: .up
                                )
                                
                                MetricCard(
                                    title: "Runtime",
                                    value: formatTime(timeElapsed),
                                    subtitle: "elapsed",
                                    icon: "clock.fill",
                                    color: .pink,
                                    trend: .stable
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NetworkArchitectureLabel(layers: networkConfig.layers)
                            .padding(.trailing, 24)
                            .padding(.bottom, 40)
                    }
                }
            }
        }
        .onAppear {
            initializeNetwork()
            startUltraAnimation()
            startMetricsTracking()
        }
    }
    
    struct NetworkConfig {
        let layers: [Int]
        let signalSpeed: CGFloat
        let signalSpawnRate: Double
        let maxActiveSignals: Int
    }
    
    struct Signal: Identifiable {
        let id = UUID()
        var progress: CGFloat
        let path: [CGPoint]
        var isActive: Bool = true
        let color: Color
        let intensity: CGFloat
        var trail: [CGPoint] = []
        let startLayer: Int
        let endLayer: Int
        let type: SignalType
        
        enum SignalType {
            case forward, backward, lateral
        }
    }
    
    struct NodeState {
        var activation: CGFloat = 0
        var lastActivation: Date = Date()
        var pulsePhase: CGFloat = 0
        var processingLoad: CGFloat = 0
    }
    
    enum Trend {
        case up, down, stable
    }
    
    func calculateNodePositions(size: CGSize) -> [[CGPoint]] {
        var positions: [[CGPoint]] = []
        let horizontalSpacing = size.width / CGFloat(networkConfig.layers.count + 1)
        let padding: CGFloat = 80
        
        for (layerIndex, nodeCount) in networkConfig.layers.enumerated() {
            var layerPositions: [CGPoint] = []
            let availableHeight = size.height - 2 * padding
            let verticalSpacing = availableHeight / CGFloat(nodeCount + 1)
            
            for nodeIndex in 0..<nodeCount {
                let x = horizontalSpacing * CGFloat(layerIndex + 1)
                let y = padding + verticalSpacing * CGFloat(nodeIndex + 1)
                let waveOffset = sin(CGFloat(layerIndex) * 0.8 + CGFloat(nodeIndex) * 0.4) * 12
                let layerCurve = cos(CGFloat(layerIndex) * 0.3) * 8
                
                layerPositions.append(CGPoint(x: x + waveOffset, y: y + layerCurve))
            }
            positions.append(layerPositions)
        }
        
        return positions
    }
    
    func drawQuantumConnections(context: GraphicsContext, positions: [[CGPoint]]) {
        for i in 0..<positions.count - 1 {
            let currentLayer = positions[i]
            let nextLayer = positions[i + 1]
            
            for (currentIdx, currentNode) in currentLayer.enumerated() {
                for (nextIdx, nextNode) in nextLayer.enumerated() {
                    let connectionActive = isConnectionActive(
                        fromLayer: i, fromNode: currentIdx,
                        toLayer: i + 1, toNode: nextIdx
                    )
                    
                    let connectionStrength = getConnectionStrength(
                        fromLayer: i, fromNode: currentIdx,
                        toLayer: i + 1, toNode: nextIdx
                    )
                    
                    var path = Path()
                    let distance = nextNode.x - currentNode.x
                    let controlPoint1 = CGPoint(
                        x: currentNode.x + distance * 0.35,
                        y: currentNode.y + sin(pulseAnimation + CGFloat(currentIdx)) * 5
                    )
                    let controlPoint2 = CGPoint(
                        x: currentNode.x + distance * 0.65,
                        y: nextNode.y + cos(pulseAnimation + CGFloat(nextIdx)) * 5
                    )
                    
                    path.move(to: currentNode)
                    path.addCurve(to: nextNode, control1: controlPoint1, control2: controlPoint2)
                    
                    if connectionActive {
                        let flowGradient = Gradient(colors: [
                            Color.cyan.opacity(0.8 * Double(connectionStrength)),
                            Color.blue.opacity(0.6 * Double(connectionStrength)),
                            Color.purple.opacity(0.7 * Double(connectionStrength)),
                            Color.pink.opacity(0.5 * Double(connectionStrength))
                        ])
                        
                        context.stroke(
                            path,
                            with: .linearGradient(
                                flowGradient,
                                startPoint: currentNode,
                                endPoint: nextNode
                            ),
                            lineWidth: 2.5 + connectionStrength * 1.5
                        )
                        context.stroke(
                            path,
                            with: .color(.white.opacity(Double(connectionStrength * 0.3))),
                            lineWidth: 4 + connectionStrength * 2
                        )
                    } else {

                        context.stroke(
                            path,
                            with: .color(.white.opacity(0.06)),
                            lineWidth: 1
                        )
                    }
                }
            }
        }
    }
    func drawPremiumSignals(context: GraphicsContext, positions: [[CGPoint]], size: CGSize) {
        for signal in signals where signal.isActive {
            let pathIndex = min(Int(signal.progress * CGFloat(signal.path.count - 1)), signal.path.count - 1)
            
            if pathIndex < signal.path.count {
                let position = signal.path[pathIndex]
                let trailLength = min(25, pathIndex)
                for i in 0..<trailLength {
                    let trailIndex = pathIndex - i
                    if trailIndex >= 0 && trailIndex < signal.path.count {
                        let trailPos = signal.path[trailIndex]
                        let fadeRatio = CGFloat(trailLength - i) / CGFloat(trailLength)
                        let trailOpacity = fadeRatio * 0.5 * signal.intensity
                        let trailSize = 4 + fadeRatio * 4
                        
                        context.fill(
                            Circle().path(in: CGRect(
                                x: trailPos.x - trailSize / 2,
                                y: trailPos.y - trailSize / 2,
                                width: trailSize,
                                height: trailSize
                            )),
                            with: .color(signal.color.opacity(Double(trailOpacity)))
                        )
                    }
                }
                let outerHaloSize: CGFloat = 60 + sin(pulseAnimation * 2 + CGFloat(signal.id.hashValue)) * 12
                context.fill(
                    Circle().path(in: CGRect(
                        x: position.x - outerHaloSize / 2,
                        y: position.y - outerHaloSize / 2,
                        width: outerHaloSize,
                        height: outerHaloSize
                    )),
                    with: .radialGradient(
                        Gradient(colors: [
                            signal.color.opacity(0.4 * Double(signal.intensity)),
                            signal.color.opacity(0.2 * Double(signal.intensity)),
                            Color.clear
                        ]),
                        center: position,
                        startRadius: 0,
                        endRadius: outerHaloSize / 2
                    )
                )
                let middleHaloSize: CGFloat = 35
                context.fill(
                    Circle().path(in: CGRect(
                        x: position.x - middleHaloSize / 2,
                        y: position.y - middleHaloSize / 2,
                        width: middleHaloSize,
                        height: middleHaloSize
                    )),
                    with: .radialGradient(
                        Gradient(colors: [
                            signal.color.opacity(0.7),
                            signal.color.opacity(0.4),
                            Color.clear
                        ]),
                        center: position,
                        startRadius: 0,
                        endRadius: middleHaloSize / 2
                    )
                )
                context.fill(
                    Circle().path(in: CGRect(
                        x: position.x - 16,
                        y: position.y - 16,
                        width: 32,
                        height: 32
                    )),
                    with: .radialGradient(
                        Gradient(colors: [
                            .white.opacity(0.9),
                            signal.color.opacity(0.8),
                            signal.color.opacity(0.3)
                        ]),
                        center: position,
                        startRadius: 0,
                        endRadius: 16
                    )
                )
                context.fill(
                    Circle().path(in: CGRect(
                        x: position.x - 7,
                        y: position.y - 7,
                        width: 14,
                        height: 14
                    )),
                    with: .color(.white)
                )
                context.fill(
                    Circle().path(in: CGRect(
                        x: position.x - 3,
                        y: position.y - 3,
                        width: 6,
                        height: 6
                    )),
                    with: .color(signal.color)
                )
                if signal.type == .forward {
                    drawDirectionalIndicator(context: context, at: position, angle: 0, color: signal.color)
                }
            }
        }
    }
    
    func drawDirectionalIndicator(context: GraphicsContext, at position: CGPoint, angle: CGFloat, color: Color) {
        let size: CGFloat = 8
        var path = Path()
        path.move(to: CGPoint(x: position.x + size, y: position.y))
        path.addLine(to: CGPoint(x: position.x + size + 6, y: position.y - 4))
        path.addLine(to: CGPoint(x: position.x + size + 6, y: position.y + 4))
        path.closeSubpath()
        
        context.fill(path, with: .color(color.opacity(0.6)))
    }
    func drawUltraNodes(context: GraphicsContext, positions: [[CGPoint]]) {
        for (layerIndex, layer) in positions.enumerated() {
            for (nodeIndex, position) in layer.enumerated() {
                let state = getNodeState(layer: layerIndex, node: nodeIndex)
                let activation = state.activation
                let processingLoad = state.processingLoad
                if activation > 0.15 {
                    let ambientSize: CGFloat = 50 + activation * 25
                    context.fill(
                        Circle().path(in: CGRect(
                            x: position.x - ambientSize / 2,
                            y: position.y - ambientSize / 2,
                            width: ambientSize,
                            height: ambientSize
                        )),
                        with: .radialGradient(
                            Gradient(colors: [
                                Color.cyan.opacity(Double(activation * 0.5)),
                                Color.blue.opacity(Double(activation * 0.3)),
                                Color.purple.opacity(Double(activation * 0.2)),
                                Color.clear
                            ]),
                            center: position,
                            startRadius: 0,
                            endRadius: ambientSize / 2
                        )
                    )
                }
                let ringSize: CGFloat = 24 + activation * 8 + sin(pulseAnimation + CGFloat(nodeIndex)) * 3
                let ringGradient = AngularGradient(
                    gradient: Gradient(colors: [
                        activation > 0.2 ? Color.cyan : Color.white.opacity(0.3),
                        activation > 0.2 ? Color.blue : Color.white.opacity(0.2),
                        activation > 0.2 ? Color.purple : Color.white.opacity(0.3)
                    ]),
                    center: UnitPoint(x: 0.5, y: 0.5)
                )
                
                context.stroke(
                    Circle().path(in: CGRect(
                        x: position.x - ringSize / 2,
                        y: position.y - ringSize / 2,
                        width: ringSize,
                        height: ringSize
                    )),
                    with: .color(activation > 0.2 ? Color.cyan.opacity(0.9) : .white.opacity(0.25)),
                    lineWidth: 2.5
                )
                if activation > 0.3 {
                    let innerRingSize = ringSize * 0.7
                    context.stroke(
                        Circle().path(in: CGRect(
                            x: position.x - innerRingSize / 2,
                            y: position.y - innerRingSize / 2,
                            width: innerRingSize,
                            height: innerRingSize
                        )),
                        with: .color(Color.white.opacity(Double(activation * 0.5))),
                        lineWidth: 1.5
                    )
                }
                let nodeSize: CGFloat = 16 + activation * 8
                let nodeGradient = Gradient(colors: [
                    activation > 0.2 ? Color.white : Color.white.opacity(0.5),
                    activation > 0.2 ? Color.cyan : Color.white.opacity(0.4),
                    activation > 0.2 ? Color.blue : Color.white.opacity(0.3)
                ])
                
                context.fill(
                    Circle().path(in: CGRect(
                        x: position.x - nodeSize / 2,
                        y: position.y - nodeSize / 2,
                        width: nodeSize,
                        height: nodeSize
                    )),
                    with: .radialGradient(
                        nodeGradient,
                        center: position,
                        startRadius: 0,
                        endRadius: nodeSize / 2
                    )
                )
                if activation > 0.6 {
                    context.fill(
                        Circle().path(in: CGRect(
                            x: position.x - 4,
                            y: position.y - 4,
                            width: 8,
                            height: 8
                        )),
                        with: .color(.white)
                    )
                }
                if processingLoad > 0.5 {
                    let indicatorSize: CGFloat = 6
                    context.fill(
                        Circle().path(in: CGRect(
                            x: position.x + nodeSize / 2 - indicatorSize / 2,
                            y: position.y - nodeSize / 2 - indicatorSize / 2,
                            width: indicatorSize,
                            height: indicatorSize
                        )),
                        with: .color(Color.green.opacity(Double(processingLoad)))
                    )
                }
            }
        }
    }
    
    func drawNetworkMetrics(context: GraphicsContext, size: CGSize) {
        let activeSignalCount = signals.filter { $0.isActive }.count
        let totalActivation = nodeStates.flatMap { $0 }.reduce(0) { $0 + $1.activation }
        let avgProcessingLoad = nodeStates.flatMap { $0 }.reduce(0) { $0 + $1.processingLoad } / CGFloat(nodeStates.flatMap { $0 }.count)
        DispatchQueue.main.async {
            globalEnergy = min(1.0, totalActivation / 30.0)
            dataFlow = CGFloat(activeSignalCount) / CGFloat(networkConfig.maxActiveSignals)
            processingSpeed = CGFloat(activeSignalCount) * 42.7 + CGFloat.random(in: -5...5)
            if networkAccuracy < 98.5 {
                networkAccuracy += 0.02
            }
        }
    }
    
    func getNodeState(layer: Int, node: Int) -> NodeState {
        guard layer < nodeStates.count, node < nodeStates[layer].count else {
            return NodeState()
        }
        return nodeStates[layer][node]
    }
    
    func isConnectionActive(fromLayer: Int, fromNode: Int, toLayer: Int, toNode: Int) -> Bool {
        let fromState = getNodeState(layer: fromLayer, node: fromNode)
        let toState = getNodeState(layer: toLayer, node: toNode)
        return fromState.activation > 0.15 || toState.activation > 0.15
    }
    
    func getConnectionStrength(fromLayer: Int, fromNode: Int, toLayer: Int, toNode: Int) -> CGFloat {
        let fromState = getNodeState(layer: fromLayer, node: fromNode)
        let toState = getNodeState(layer: toLayer, node: toNode)
        return (fromState.activation + toState.activation) / 2.0
    }
    
    func formatTime(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func initializeNetwork() {
        nodeStates = networkConfig.layers.map { nodeCount in
            Array(repeating: NodeState(), count: nodeCount)
        }
        networkAccuracy = 92.0
    }
    func startUltraAnimation() {
        // Signal generation timer
        Timer.scheduledTimer(withTimeInterval: networkConfig.signalSpawnRate, repeats: true) { _ in
            if signals.filter({ $0.isActive }).count < networkConfig.maxActiveSignals {
                createPremiumSignal()
            }
        }
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            updateAllNetworkStates()
        }
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            pulseAnimation = .pi * 2
        }
    }
    
    func startMetricsTracking() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            timeElapsed += 1
            totalProcessed += Int.random(in: 5...12)
        }
    }
    
    func createPremiumSignal() {
        let size = UIScreen.main.bounds.size
        let positions = calculateNodePositions(size: size)
        
        let startLayer = 0
        let endLayer = positions.count - 1
        
        var path: [CGPoint] = []
        var currentNodeIndex = Int.random(in: 0..<positions[startLayer].count)
        
        for layerIndex in startLayer...endLayer {
            let layer = positions[layerIndex]
            let currentNode = layer[currentNodeIndex]
            
            if let lastPoint = path.last {
                let steps = 30
                for i in 0...steps {
                    let t = CGFloat(i) / CGFloat(steps)
                    let easeT = easeInOutCubic(t)
                    let x = lastPoint.x + (currentNode.x - lastPoint.x) * easeT
                    let y = lastPoint.y + (currentNode.y - lastPoint.y) * easeT
                    path.append(CGPoint(x: x, y: y))
                }
            } else {
                path.append(currentNode)
            }
            
            if layerIndex < endLayer {
                currentNodeIndex = Int.random(in: 0..<positions[layerIndex + 1].count)
            }
        }
        
        let colors: [Color] = [.cyan, .blue, .purple, .pink, .mint, .indigo, .teal]
        let signalTypes: [Signal.SignalType] = [.forward, .forward, .forward, .lateral]
        
        let signal = Signal(
            progress: 0,
            path: path,
            color: colors.randomElement() ?? .cyan,
            intensity: CGFloat.random(in: 0.7...1.0),
            startLayer: startLayer,
            endLayer: endLayer,
            type: signalTypes.randomElement() ?? .forward
        )
        
        signals.append(signal)
    }
    
    func easeInOutCubic(_ t: CGFloat) -> CGFloat {
        return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }
    
    func updateAllNetworkStates() {
        withAnimation(.easeOut(duration: 0.1)) {
            // Update signals
            for i in 0..<signals.count {
                signals[i].progress += networkConfig.signalSpeed
                
                if signals[i].progress >= 1.0 {
                    signals[i].isActive = false
                }
            }
            let size = UIScreen.main.bounds.size
            let positions = calculateNodePositions(size: size)
            
            for (layerIndex, layer) in positions.enumerated() {
                for (nodeIndex, nodePos) in layer.enumerated() {
                    var maxActivation: CGFloat = 0
                    var processingLoad: CGFloat = 0
                    
                    for signal in signals where signal.isActive {
                        let pathIndex = Int(signal.progress * CGFloat(signal.path.count - 1))
                        if pathIndex < signal.path.count {
                            let signalPos = signal.path[pathIndex]
                            let distance = hypot(nodePos.x - signalPos.x, nodePos.y - signalPos.y)
                            
                            if distance < 35 {
                                let activation = (35 - distance) / 35 * signal.intensity
                                maxActivation = max(maxActivation, activation)
                                processingLoad += activation * 0.5
                            }
                        }
                    }
                    
                    nodeStates[layerIndex][nodeIndex].activation = maxActivation
                    nodeStates[layerIndex][nodeIndex].processingLoad = min(1.0, processingLoad)
                    if maxActivation == 0 {
                        nodeStates[layerIndex][nodeIndex].activation *= 0.88
                        nodeStates[layerIndex][nodeIndex].processingLoad *= 0.92
                    }
                }
            }
            signals.removeAll { !$0.isActive }
        }
    }
}

struct AdvancedBackground: View {
    let energy: CGFloat
    let dataFlow: CGFloat
    @State private var particleOffset: CGFloat = 0
    @State private var waveOffset: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.01, green: 0.01, blue: 0.08),
                    Color(red: 0.03, green: 0.02, blue: 0.12 + Double(energy) * 0.08),
                    Color(red: 0.06, green: 0.03, blue: 0.18 + Double(energy) * 0.12),
                    Color(red: 0.08, green: 0.05, blue: 0.22 + Double(energy) * 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Canvas { context, size in
                for i in 0..<50 {
                    let x = (CGFloat(i) * size.width / 50 + waveOffset * 0.3).truncatingRemainder(dividingBy: size.width)
                    let y = (CGFloat(i * 23) + particleOffset + sin(CGFloat(i) * 0.5 + waveOffset) * 30).truncatingRemainder(dividingBy: size.height)
                    let opacity = (energy * 0.4 + 0.1) * (0.5 + sin(CGFloat(i) + waveOffset) * 0.5)
                    let size = 2.0 + energy * 2.0
                    
                    context.fill(
                        Circle().path(in: CGRect(x: x, y: y, width: size, height: size)),
                        with: .color(.cyan.opacity(Double(opacity)))
                    )
                }
                for i in 0..<20 {
                    let x = CGFloat(i) * size.width / 20
                    let y = (size.height * 0.5 + sin(waveOffset + CGFloat(i) * 0.3) * 100 * dataFlow)
                    let opacity = dataFlow * 0.3
                    
                    context.fill(
                        Circle().path(in: CGRect(x: x, y: y, width: 3, height: 3)),
                        with: .color(.blue.opacity(Double(opacity)))
                    )
                }
            }
            Canvas { context, size in
                var path = Path()
                path.move(to: CGPoint(x: 0, y: size.height * 0.3))
                
                for x in stride(from: 0, through: size.width, by: 10) {
                    let y = size.height * 0.3 + sin(x * 0.02 + waveOffset) * 50 * energy
                    path.addLine(to: CGPoint(x: x, y: y))
                }
                
                context.stroke(path, with: .color(.cyan.opacity(Double(energy * 0.2))), lineWidth: 2)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 25).repeatForever(autoreverses: false)) {
                particleOffset = UIScreen.main.bounds.height
            }
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                waveOffset = .pi * 4
            }
        }
    }
}
struct StatusBadge: View {
    let icon: String
    let label: String
    let status: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
                    .textCase(.uppercase)
                
                Text(status)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(color)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.4), lineWidth: 1)
                )
        )
        .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    let trend: NeuralNetworkView.Trend
    
    @State private var animateValue: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Spacer()
                
                TrendIndicator(trend: trend, color: color)
            }
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .scaleEffect(animateValue ? 1.05 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6).repeatForever(autoreverses: true), value: animateValue)
            
            HStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .textCase(.uppercase)
                
                Text("•")
                    .foregroundColor(.white.opacity(0.3))
                
                Text(subtitle)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.4), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
        .onAppear {
            animateValue = true
        }
    }
}
struct TrendIndicator: View {
    let trend: NeuralNetworkView.Trend
    let color: Color
    
    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: trendIcon)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(trendColor)
            
            Circle()
                .fill(trendColor)
                .frame(width: 6, height: 6)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(trendColor.opacity(0.15))
        )
    }
    
    var trendIcon: String {
        switch trend {
        case .up: return "arrow.up"
        case .down: return "arrow.down"
        case .stable: return "minus"
        }
    }
    
    var trendColor: Color {
        switch trend {
        case .up: return .green
        case .down: return .red
        case .stable: return .orange
        }
    }
}

struct NetworkArchitectureLabel: View {
    let layers: [Int]
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Text("Architecture")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
                .textCase(.uppercase)
            
            Text(architectureString)
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.cyan, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.cyan.opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: .cyan.opacity(0.2), radius: 8, x: 0, y: 4)
    }
    
    var architectureString: String {
        layers.map { String($0) }.joined(separator: " → ")
    }
}

#Preview {
    NeuralNetworkView()
}
