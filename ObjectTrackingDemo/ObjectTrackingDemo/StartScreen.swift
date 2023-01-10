//
//  StartScreen.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 10/01/2023.
//

import SwiftUI

struct StartScreen: View {
    @Environment(\.dismiss) var dismiss
    @State private var isShow: Bool = false
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Wählen Sie die gewünschte Abteilung oder Marke im Geschäft aus")
                        .font(Font.custom("Roboto-Bold", size: 20))
                        .multilineTextAlignment(.center)
                        .padding()
                    Image("background")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .overlay {
                            HStack {
                                Button {
                                    self.isShow = true
                                } label: {
                                    Image("nike")
                                }.offset(x: 60, y: -210)
                                Button {
                                    self.isShow = true
                                } label: {
                                    Image("kipsta")
                                }.offset(x: 90, y: -150)
                            }
                        }
                    Button {
                        self.isShow = true
                    } label: {
                        Text("skip")
                            .font(Font.custom("Roboto-Regular", size: 20))
                            .foregroundColor(.black)
                    }.padding([.top, .bottom])
                }
                .navigationDestination(isPresented: $isShow) {
                    MainScreen()
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
                .onAppear {
                    self.isShow = false
                }
            }
        }
    }
}

struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
    }
}
