//
//  DetailShoeScreen.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct DetailShoeView: View {
    @Environment(\.dismiss) var dismiss
    @State private var showCameraScreen: Bool = false
    var body: some View {
            ScrollView {
                VStack {
                    Image("airForce")
                        .resizable()
                        .frame(height: 350)
                    VStack(alignment: .leading) {
                        Button {
                            self.showCameraScreen = true
                        } label: {
                            HStack {
                                Image("ar_button")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                Text("Try it now")
                                    .font(Font.custom("Roboto-Regular", size: 13))
                                    .foregroundColor(.black)
                            }.padding(.leading, 5)
                        }
                        .offset(x:0, y: -50)
                        .padding(.top)
                        RoundedRectangle(cornerRadius: 8)
                            .overlay {
                                Text("NIKE")
                                    .font(Font.custom("Roboto-Regular", size: 12))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 47, height: 32)
                            .padding(.top)
                        Text("Sneaker low Air Max 97 SE W Damen")
                            .lineLimit(2, reservesSpace: true)
                            .font(Font.custom("Roboto-Bold", size: 26))
                            .padding(.top)
                        HStack {
                            BewertungetLabel()
                            Spacer()
                            Text("190,00€*")
                                .frame(width: 95, height: 29)
                                .background {
                                    Color.yellow
                                }
                        }
                        .padding(.top)
                        Text("Produktinformation")
                            .font(Font.custom("Roboto-Bold", size: 20))
                            .padding(.top)
                        Text("ID: 5bc3f493-8...")
                            .font(Font.custom("Roboto-Regular", size: 12))
                            .padding(.top)
                        HStack {
                            Circle()
                                .frame(width: 9, height: 9)
                                .foregroundColor(.green)
                            Text("Verfugbar")
                            Spacer()
                            Text("38,39")
                        }
                        .padding(.top)
                        Button {} label: {
                            RoundedRectangle(cornerRadius: 8)
                                .overlay {
                                    HStack {
                                        Spacer()
                                        Text("Auswählen")
                                            .foregroundColor(.black)
                                        Spacer()
                                        Image(systemName: "cart")
                                            .resizable()
                                            .foregroundColor(.black)
                                            .frame(width: 18, height: 18)
                                            .padding(.trailing, 10)
                                    }
                                }
                                .foregroundColor(Color.yellow)
                        }
                        .frame(height: 43)
                        .padding(.top)
                    }.padding([.leading, .trailing], 25)
                }
            }
            .toolbar(.hidden, for: .tabBar)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        dismiss()
                    }
                label: {
                    Image(systemName: "chevron.left")
                        .resizable()
                        .foregroundColor(.black)
                        .frame(width: 9.38, height: 17.47)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 15) {
                        Button {} label: {
                            Image("shareButton")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 16, height: 16)
                        }
                        Button {} label: {
                            Image(systemName: "heart")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 16, height: 13.65)
                        }
                    }
                }
            })
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showCameraScreen) {
                ContentView()
                    .toolbar(.hidden, for: .tabBar)
                    .ignoresSafeArea(.all)
            }
    }
}

struct DetailShoeScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailShoeView()
    }
}
