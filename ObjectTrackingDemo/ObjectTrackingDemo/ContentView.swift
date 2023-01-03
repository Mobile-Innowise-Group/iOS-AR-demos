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
    var body: some View {
        ObjectTrackingWrap()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
