//
//  TeachingView.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct ScanIntroductionView: View {
    var completion: (() -> Void)?
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .dark))
                .edgesIgnoringSafeArea(.all)
            VStack {
                HStack() {
                    Spacer()
                    Button {
                        completion?()
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
                        .padding([.leading, .trailing, .bottom])
                    Text("Sie müssen ein Bein von allen Seiten scannen, bis die Ebenen gelb gefärbt sind")
                        .multilineTextAlignment(.center)
                        .font(Font.custom("Roboto-Regular", size: 16))
                        .padding()
                    Image("fixedImg")
                        .resizable()
                        .frame(width: 355, height: 445)
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(.white)
            }
            .padding(.all, 30)
        }
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct ScanIntroductionView_Previews: PreviewProvider {
    static var previews: some View {
        ScanIntroductionView()
    }
}
