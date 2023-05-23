//
//  FloatingActionButtonWithListView.swift
//  FloatingActionButton
//
//  Created by Will Ellis on 5/22/23.
//

import SwiftUI

struct BoundsPreferenceKey: PreferenceKey {
    typealias Value = Anchor<CGRect>?

    static var defaultValue: Value = nil

    static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = nextValue()
    }
}

struct FloatingActionButtonWithListView: View {
    @State var text = ""

    var body: some View {
        VStack {
            Spacer()
                .border(Color.pink)
            HStack {
                Spacer()
                Button("Button", action: {})
                    .buttonStyle(.borderedProminent)
                    .anchorPreference(
                        key: BoundsPreferenceKey.self,
                        value: .bounds
                    ) { boundsAnchor in
                        boundsAnchor
                    }
                Spacer()
            }
        }
        .ignoresSafeArea(.keyboard)
        .backgroundPreferenceValue(BoundsPreferenceKey.self) { preferences in
            GeometryReader { geometryProxy in
                preferences.map { anchor in
                    List(0..<50) { _ in
                        TextField("Title", text: $text)
                    }
                    .safeAreaInset(edge: .bottom) {
                        // Inset by the height of the button
                        Spacer()
                            .frame(height: geometryProxy[anchor].height)
                    }
                }
            }
        }
    }
}

struct FloatingActionButtonWithListView_Previews: PreviewProvider {
    static var previews: some View {
        FloatingActionButtonWithListView()
    }
}
