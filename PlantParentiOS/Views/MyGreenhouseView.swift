import SwiftUI

struct MyGreenhouseView: View {
    @EnvironmentObject private var greenhouse: GreenhouseStore
    
    @State private var showRemoveAlert: Bool = false
    @State private var plantToRemove: GreenhousePlant? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("My Greenhouse 🌿")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)
                    
                    HStack {
                        Text("My Plants")
                            .font(.title2)
                            .bold()
                        Spacer()
                        if !greenhouse.plants.isEmpty {
                            Text("\(greenhouse.plants.count)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.horizontal)
                    
                    if greenhouse.plants.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "leaf")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Your greenhouse is empty")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Text("Add plants from the Home tab to see them here.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 40)
                    } else {
                        ForEach(greenhouse.plants) { plant in
                            PlantCardView(plant: plant, onDelete: {
                                plantToRemove = plant
                                showRemoveAlert = true
                            }, onWatered: {
                                greenhouse.markWatered(for: plant)
                            })
                            .padding(.horizontal)
                            .id(plant.id)
                        }
                    }
                }
                .padding(.bottom, 50)
                .alert("Remove Plant?", isPresented: $showRemoveAlert, presenting: plantToRemove) { plant in
                    Button("Remove", role: .destructive) {
                        greenhouse.remove(plant)
                        plantToRemove = nil
                        showRemoveAlert = false
                    }
                    Button("Cancel", role: .cancel) { }
                } message: { plant in
                    Text("Are you sure you want to remove \"\(plant.displayName)\" from your greenhouse?")
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(.systemGroupedBackground), Color(.systemGreen).opacity(0.15)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
        }
    }
}

struct GreenhouseView_Previews: PreviewProvider {
    static var previews: some View {
        MyGreenhouseView()
            .environmentObject(GreenhouseStore())
    }
}
