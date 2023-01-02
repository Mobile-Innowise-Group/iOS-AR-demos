//
//  SwipeItemsView.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct FakeSwipeItem: View {
    var body: some View {
        ZStack{}
    }
}

struct LeftSwipeItem: View {
    var completion: (() -> Void)?
    var body: some View {
        HStack {
            SwipeItemButton(sysImage: "arkit", buttonText: "AR Anprobe") {
                completion?()
            }
            SwipeItemButton(sysImage: "heart", buttonText: "Zur Wunschliste") {}
        }
    }
}
