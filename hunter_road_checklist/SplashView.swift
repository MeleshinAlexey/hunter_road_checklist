//
//  SplashView.swift
//  hunter_road_checklist
//
//  Created by Alexey Meleshin on 11/26/25.
//

import SwiftUI

struct SplashView: View {

    @State private var shouldNavigate = false

    var body: some View {
        ZStack {
            Color(red: 39/255.0, green: 46/255.0, blue: 75/255.0)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image("icon_chicken_empty")    
                    .resizable()
                    .scaledToFit()
                    .frame(width: 160, height: 160)

                Text("Hunter Road Checklist")
                    .foregroundColor(.white)
                    .font(.system(size: 26, weight: .semibold))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation(.easeInOut) {
                    shouldNavigate = true
                }
            }
        }
        .fullScreenCover(isPresented: $shouldNavigate) {
            RootTabView()
        }
    }
}
