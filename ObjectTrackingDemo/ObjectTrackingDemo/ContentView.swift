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
    @Environment(\.presentationMode) var presentationMode
    @State private var show: Bool = true
    var body: some View {
        ObjectTrackingWrap()
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.white)
                    }
                }
            })
            .navigationBarBackButtonHidden(true)
    }
}
