//
//  CameraSheetView.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 03/01/2023.
//

import SwiftUI

struct TestBottomSheet: View {
    @State private var show: Bool = false
    var body: some View {
        VStack {
            Button {
                self.show = true
            } label: {
                Text("Show")
            }
        }
//        .popup(isPresented: $show) {
//            ScanIntroductionView()
//        }
        .sheet(isPresented: $show) {
            CameraSheetView()
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.23), .fraction(0.6)])
        }
    }
}

struct CameraSheetView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack {
                    HStack(alignment: .top) {
                        RoundedRectangle(cornerRadius: 8)
                            .overlay {
                                Text("NIKE")
                                    .font(Font.custom("Roboto-Regular", size: 12))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 47, height: 32)
                            .padding([.trailing, .bottom])
                        Text("Sneaker low Air Max 97 SE W Damen")
                            .font(Font.custom("Roboto-Bold", size: 18))
                            .lineLimit(2, reservesSpace: true)
                            .padding([.trailing, .bottom])
                        Button {} label: {
                            Image(systemName: "heart")
                                .resizable()
                                .frame(width: 20, height: 18)
                                .foregroundColor(.gray)
                        }.padding([.leading, .bottom])
                    }.padding(.top, 30)
                    HStack {
                        Image("airForce")
                            .resizable()
                            .frame(width: 138, height: 115)
                        VStack(alignment: .leading) {
                            BewertungetLabel()
                            Button {} label: {
                                HStack {
                                    Text("Auswählen")
                                        .font(Font.custom("Roboto-Bold", size: 18))
                                        .foregroundColor(.black)
                                    Text("190,00€*")
                                        .font(Font.custom("Roboto-Bold", size: 18))
                                        .foregroundColor(.black)
                                }.padding()
                                    .frame(height: 53)
                            }.background {
                                Color.yellow
                            }
                        }
                    }
                }
                VStack(alignment: .leading) {
                    Text("Produktinformation")
                        .font(Font.custom("Roboto-Bold", size: 18))
                        .padding(.bottom)
                    Text("ID: 5bc3f493-8...")
                        .font(Font.custom("Roboto-Regular", size: 18))
                        .padding(.bottom)
                    Text("Dieser Schuh vereint klassische Formen mit maximalem Tragekomfort. Das Design mit Wellenlinien, reflektierenden Highlights und dezenten Logo-Stickereien sorgt für eine unverwechselbare Silhuouette. Der Nike Air Max 97 SE Women Schuh ist ein Kult-Sneaker und der Hingucker in deinem Street-Style. Dieser Schuh vereint klassische Formen mit maximalem Tragekomfort. Das Design mit Wellenlinien, reflektierenden Highlights und dezenten Logo-Stickereien sorgt für eine unverwechselbare Silhuouette. Dieser sehr bequeme Sneaker überzeugt nicht nur in Sachen Optik, sondern auch mit seinem strapazierfähigem Obermaterial aus Lederimitat und Textil. Das durchgehende Air-Max-Element in der Sohle verspricht einen leichtgewichtige und außergewöhnlich gute Schrittdämpfung. Produktinformationen")
                        .font(Font.custom("Roboto-Regular", size: 18))
                }
            }.padding([.leading, .trailing], 30)
        }
    }
}

struct CameraSheetView_Previews: PreviewProvider {
    static var previews: some View {
        TestBottomSheet()
    }
}

struct CameraSheetView2_Previews: PreviewProvider {
    static var previews: some View {
        CameraSheetView()
    }
}
