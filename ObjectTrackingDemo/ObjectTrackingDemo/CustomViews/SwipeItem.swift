//
//  SwipeLogic.swift
//  ObjectTrackingDemo
//
//  Created by Sergey Luk on 02/01/2023.
//

import SwiftUI

struct SwipeItem<Content: View, Left: View, Right: View>: View {
    var content: () -> Content
    var left: () -> Left
    var right: () -> Right
    var itemHeight: CGFloat
    
    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder left: @escaping () -> Left,
        @ViewBuilder right: @escaping () -> Right,
        itemHeight: CGFloat
    ) {
        self.content = content
        self.left = left
        self.right = right
        self.itemHeight = itemHeight
    }
    
    @State var hoffset: CGFloat = 0.0
    @State var anchor: CGFloat = 0.0
    @State var leftPast: Bool = false
    @State var rightPast: Bool = false
    
    let screenWidth = UIScreen.main.bounds.width
    var anchorWidth: CGFloat { screenWidth / 3 }
    var swipeTreshold: CGFloat { screenWidth / 15 }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    hoffset = anchor + value.translation.width
                    
                    if abs(hoffset) > anchorWidth {
                        if leftPast {
                            hoffset = -anchorWidth
                        } else if rightPast {
                            hoffset = -anchorWidth
                        }
                    }
                    
                    if anchor < 0 {
                        rightPast = hoffset < -anchorWidth + swipeTreshold
                    } else {
                        rightPast = hoffset < -swipeTreshold
                    }
                }
            }
            .onEnded { value in
                withAnimation {
                    if rightPast {
                        anchor = -anchorWidth
                    } else if leftPast {
                        anchor = anchorWidth
                    } else {
                        anchor = 0
                    }
                    hoffset = anchor
                }
            }
    }
    
    var body: some View {
        GeometryReader { reader in
            HStack(spacing: 0) {
                left()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .clipped()
                content()
                    .frame(width: reader.size.width)
                right()
                    .frame(width: anchorWidth)
                    .zIndex(1)
                    .clipped()
            }
        }
        .offset(x: -anchorWidth + hoffset)
        .frame(minHeight: itemHeight)
        .contentShape(Rectangle())
        .gesture(drag)
        .clipped()
    }
}
