//
//  MainScreen.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 30/12/2022.
//

import SwiftUI

struct MainScreen: View {
    var body: some View {
        TabView {
            FilterScreen()
                .tabItem {
                    Label("",systemImage: "house")
                }
            FilterScreen()
                .tabItem {
                    Label("",systemImage: "doc.text.magnifyingglass")
                }
            FilterScreen()
                .tabItem {
                    Label("", systemImage: "person")
                }
            FilterScreen()
                .tabItem {
                    Label("", systemImage: "heart")
                }
            FilterScreen()
                .tabItem {
                    Label("", systemImage: "cart")
                }
        }
    }
}
