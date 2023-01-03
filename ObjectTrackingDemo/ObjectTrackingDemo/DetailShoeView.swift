//
//  DetailShoeScreen.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct DetailShoeView: View {
    @Environment(\.presentationMode) var presentationMode
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
                            Image(systemName: "arkit")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                        }
                        .padding([.leading, .bottom], 15)
                        RoundedRectangle(cornerRadius: 8)
                            .overlay {
                                Text("NIKE")
                                    .font(Font.custom("Roboto-Regular", size: 12))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 47, height: 32)
                            .padding(.leading, 15)
                        Text("Sneaker low Air Max 97 SE W Damen")
                            .lineLimit(2, reservesSpace: true)
                            .font(Font.custom("Roboto-Bold", size: 26))
                            .padding(.leading, 15)
                        HStack {
                            BewertungetLabel()
                            Spacer()
                            Text("190,00€*")
                                .frame(width: 95, height: 29)
                                .background {
                                    Color.yellow
                                }
                                .padding(.trailing, 15)
                        }.padding(.leading, 10)
                        Text("Produktinformation")
                            .font(Font.custom("Roboto-Bold", size: 20))
                            .padding()
                        Text("ID: 5bc3f493-8...")
                            .font(Font.custom("Roboto-Regular", size: 12))
                            .padding()
                    }
                    VStack {
                        HStack {
                            Circle()
                                .frame(width: 9, height: 9)
                                .foregroundColor(.green)
                            Text("Verfugbar")
                            Spacer()
                            Text("38,39")
                        }.padding()
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
                        }.frame(height: 43)
                            .padding([.leading, .trailing], 25)
                    }
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        self.presentationMode.wrappedValue.dismiss()
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
                            Image(systemName: "square.and.arrow.up")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 25, height: 25)
                        }
                        Button {} label: {
                            Image(systemName: "heart")
                                .resizable()
                                .foregroundColor(.black)
                                .frame(width: 25, height: 25)
                        }
                    }
                }
            })
            .toolbar(.hidden, for: .tabBar)
            .navigationDestination(isPresented: $showCameraScreen) {
                ContentView()
                    .toolbar(.hidden, for: .tabBar)
//                    .toolbar(.hidden, for: .navigationBar)
            }
    }
}

struct DetailShoeScreen_Previews: PreviewProvider {
    static var previews: some View {
        DetailShoeView()
    }
}
