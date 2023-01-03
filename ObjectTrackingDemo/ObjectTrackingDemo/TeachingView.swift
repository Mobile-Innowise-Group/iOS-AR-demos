//
//  TeachingView.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct TeachingView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 0)
            .overlay {
                ZStack {
                    VStack {
                        HStack() {
                            Spacer()
                            Button {
                                
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 15.5, height: 15.5)
                                    .foregroundColor(.black)
                            }.padding()
                        }
                        VStack {
                            Text("VERSUCHEN SIE, DIESE TURNSHUNE AUNZPROBIEREN")
                                .multilineTextAlignment(.center)
                                .font(Font.custom("Roboto-Bold", size: 20))
                                .padding()
                            Text("Sie müssen ein Bein von allen Seiten scannen, bis die Ebenen gelb gefärbt sind")
                                .multilineTextAlignment(.center)
                                .font(Font.custom("Roboto-Regular", size: 16))
                                .padding()
                            Image("fixedImg")
                                .resizable()
                        }
                    }
                }
                .background {
                    Color.white
                }
            }
            .edgesIgnoringSafeArea(.all)
            .cornerRadius(15)
            .padding()
            .background {
                VisualEffectView(effect: UIBlurEffect(style: .dark))
                    .edgesIgnoringSafeArea(.all)
            }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(
        _ uiView: UIVisualEffectView,
        context: UIViewRepresentableContext<Self>
    ) { uiView.effect = effect }
}

struct TeachingView_Previews: PreviewProvider {
    static var previews: some View {
        TeachingView()
    }
}
