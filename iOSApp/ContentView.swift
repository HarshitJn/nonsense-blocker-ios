import SwiftUI
import FamilyControls
import NonsenseBlockerCore

struct ContentView: View {
    @StateObject private var blockManager = BlockManager.shared
    @State private var isPickerPresented = false
    @State private var hasPermission = false
    
    // Simulator states
    @State private var showSimulator = false
    @State private var simulatorClicks = 0
    @State private var simulatorQuotes: [String] = []
    @State private var selectedIndexes: Set<Int> = []
    
    let totalRequired = 25
    
    var body: some View {
        NavigationView {
            ZStack {
                // Modern Dark Gradient Background
                LinearGradient(
                    gradient: Gradient(colors: [Color(red: 0.08, green: 0.08, blue: 0.12), Color(red: 0.04, green: 0.04, blue: 0.06)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        // Header / Hero Section
                        VStack(spacing: 12) {
                            Text("🌿")
                                .font(.system(size: 64))
                                .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Text("Nonsense Blocker")
                                .font(.system(.largeTitle, design: .rounded))
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Reclaim your life, 25 clicks at a time.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 24)
                        
                        // Status Card (Screen Time Authorization)
                        VStack(spacing: 16) {
                            HStack {
                                Text("Screen Time Authorization")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Circle()
                                    .fill(hasPermission ? Color.green : Color.red)
                                    .frame(width: 10, height: 10)
                            }
                            
                            if !hasPermission {
                                Text("Nonsense Blocker needs Screen Time access to shield distracting apps.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button(action: requestPermission) {
                                    Text("Grant Access")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .cornerRadius(12)
                                }
                            } else {
                                Text("Access Granted. Ready to block distracting habits.")
                                    .font(.caption)
                                    .foregroundColor(.green.opacity(0.8))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        // Configuration Section
                        if hasPermission {
                            VStack(spacing: 20) {
                                // App Selection Button
                                Button(action: { isPickerPresented = true }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Select Apps to Block")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("\(blockManager.activitySelection.applicationTokens.count) apps selected")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.gray)
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                .sheet(isPresented: $isPickerPresented) {
                                    FamilyActivityPicker(
                                        headerText: "Select distracting apps",
                                        selection: $blockManager.activitySelection
                                    )
                                }
                                
                                // Blocker Enable Toggle
                                Toggle(isOn: $blockManager.isBlockingEnabled) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Blocker Shield Active")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Text(blockManager.isBlockingEnabled ? "Shielding is currently ON" : "Shielding is currently OFF")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                }
                                .padding()
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(16)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                )
                                .toggleStyle(SwitchToggleStyle(tint: .green))
                            }
                            .padding(.horizontal)
                        }
                        
                        // Challenge Simulator Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Practice Pause")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                            
                            VStack(spacing: 16) {
                                Text("Simulate the 25-quote shield challenge to clear your mind right now.")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                
                                Button(action: startSimulator) {
                                    Text("Start Pause Practice")
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.blue.opacity(0.8))
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showSimulator) {
                SimulatorView(
                    quotes: simulatorQuotes,
                    selectedIndexes: $selectedIndexes,
                    totalRequired: totalRequired,
                    onDismiss: { showSimulator = false }
                )
            }
        }
        .onAppear {
            checkPermissionStatus()
        }
    }
    
    // MARK: - Actions
    
    private func checkPermissionStatus() {
        // In simulation/dev mode, check authorization state
        let status = AuthorizationCenter.shared.authorizationStatus
        hasPermission = (status == .approved)
    }
    
    private func requestPermission() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                DispatchQueue.main.async {
                    self.hasPermission = true
                }
            } catch {
                print("Failed to request permission: \(error)")
            }
        }
    }
    
    private func startSimulator() {
        // Collect 25 random quotes
        var shuffled = QuotesDatabase.quotes.shuffled()
        simulatorQuotes = Array(shuffled.prefix(totalRequired))
        selectedIndexes.removeAll()
        showSimulator = true
    }
}

// MARK: - Simulator Detail View
struct SimulatorView: View {
    let quotes: [String]
    @Binding var selectedIndexes: Set<Int>
    let totalRequired: Int
    var onDismiss: () -> Void
    
    let columns = [
        GridItem(.adaptive(minimum: 140, maximum: 200), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.08).ignoresSafeArea()
                
                VStack(spacing: 16) {
                    // Header progress
                    VStack(spacing: 8) {
                        Text("Pause Practice")
                            .font(.headline)
                            .foregroundColor(.gray)
                        Text("\(selectedIndexes.count) / \(totalRequired) Moments Cleared")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 8)
                                Capsule()
                                    .fill(Color.green)
                                    .frame(width: geo.size.width * CGFloat(selectedIndexes.count) / CGFloat(totalRequired), height: 8)
                                    .animation(.spring(), value: selectedIndexes.count)
                            }
                        }
                        .frame(height: 8)
                        .padding(.horizontal)
                    }
                    .padding(.top)
                    
                    // Grid of 25 tiles
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(0..<totalRequired, id: \.self) { index in
                                let isSelected = selectedIndexes.contains(index)
                                Button(action: {
                                    if isSelected {
                                        selectedIndexes.remove(index)
                                    } else {
                                        selectedIndexes.insert(index)
                                    }
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text(QuotesDatabase.emojis[index % QuotesDatabase.emojis.count])
                                            .font(.title)
                                        
                                        Text(quotes[index])
                                            .font(.caption2)
                                            .foregroundColor(isSelected ? .black.opacity(0.7) : .white.opacity(0.8))
                                            .lineLimit(4)
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                    }
                                    .padding(10)
                                    .frame(height: 120)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(isSelected ? Color.green : Color.white.opacity(0.06))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelected ? Color.green : Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                    }
                    
                    // Proceed/Dismiss Button
                    Button(action: onDismiss) {
                        Text(selectedIndexes.count >= totalRequired ? "Reclaimed! Let's Go ➔" : "Dismiss Practice")
                            .fontWeight(.semibold)
                            .foregroundColor(selectedIndexes.count >= totalRequired ? .black : .white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedIndexes.count >= totalRequired ? Color.green : Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .padding()
                    }
                    .disabled(selectedIndexes.count < totalRequired)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button("Cancel", action: onDismiss).foregroundColor(.white))
        }
    }
}
