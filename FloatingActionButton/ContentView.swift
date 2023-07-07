//
//  ContentView.swift
//  FloatingActionButton
//
//  Created by Will Ellis on 5/23/23.
//

import SwiftUI

struct ContentView: View {
    @State var text = ""

    var body: some View {
        List(0..<50) { _ in
            TextField("Title", text: $text)
        }
        .safeAreaInsetIgnoringKeyboard {
            Button("Button", action: {})
                .buttonStyle(.borderedProminent)
                .padding(16)
        } background: {
            Color.white
                .cornerRadius(24)
                .shadow(radius: 5)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
