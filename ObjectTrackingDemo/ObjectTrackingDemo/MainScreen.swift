//
//  MainScreen.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 30/12/2022.
//

import SwiftUI

struct MainScreen: View {
    var body: some View {
        NavigationView {
            TabView {
                FilterScreen()
                    .tabItem {
                        Label("",systemImage: "house")
                            .foregroundColor(.black)
                    }
                FilterScreen()
                    .tabItem {
                        Label("",systemImage: "doc.text.magnifyingglass")
                            .foregroundColor(.black)
                    }.disabled(true)
                FilterScreen()
                    .tabItem {
                        Label("", systemImage: "person")
                            .foregroundColor(.black)
                    }.disabled(true)
                FilterScreen()
                    .tabItem {
                        Label("", systemImage: "heart")
                            .foregroundColor(.black)
                    }.disabled(true)
                FilterScreen()
                    .tabItem {
                        Label("", systemImage: "cart")
                            .foregroundColor(.black)
                    }.disabled(true)
            }
            .accentColor(.black)
            .toolbarColorScheme(.light, for: .tabBar)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
