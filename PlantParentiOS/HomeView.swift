//
//  HomeView.swift
//  PlantParentiOS
//
//  Created by stud on 23/10/2025.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Text("Hello Plant Parent!")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "bell.badge")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                        TextField("Search", text: .constant(""))
                        Button("Filter") {
                            //Filter action
                        }
                        .foregroundColor(.green)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
