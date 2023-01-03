//
//  ContentView.swift
//  ObjectTrackingDemo
//
//  Created by Uladzislau Volchyk on 27/10/2022.
//

import SwiftUI

struct ObjectTrackingWrap: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
//        ObjectTrackingFacade.buildFlow()!
        ViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//        uiViewController.view.frame = UIScreen.main.bounds
    }
}

struct ContentView: View {
    @State private var show: Bool = true
    var body: some View {
        ObjectTrackingWrap()
            .sheet(isPresented: $show) {
                CameraSheetView()
                    .presentationDragIndicator(.visible)
                    .presentationDetents([.fraction(0.2), .fraction(0.6)])
            }
    }
}
