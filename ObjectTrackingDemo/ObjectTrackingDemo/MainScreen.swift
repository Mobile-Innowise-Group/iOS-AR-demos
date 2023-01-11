//
//  MainScreen.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 30/12/2022.
//

import SwiftUI

struct MainScreen: View {
    @Environment(\.dismiss) var dismiss
    var body: some View {
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
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .foregroundColor(.black)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .foregroundColor(.black)
                            .frame(width: 20, height: 20)
                    }                    }
            })
            .navigationBarBackButtonHidden(true)
    }
}
