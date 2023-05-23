//
//  SafeAreaInsetIgnoringKeyboardView.swift
//  FloatingActionButton
//
//  Created by Will Ellis on 5/23/23.
//

import SwiftUI

struct InsetContentPreferenceKey: PreferenceKey {
    typealias Value = Anchor<CGRect>?

    static var defaultValue: Value = nil

    static func reduce(
        value: inout Value,
        nextValue: () -> Value
    ) {
        value = nextValue()
    }
}

struct SafeAreaInsetIgnoringKeyboardView<Content: View, InsetContent: View>: View {
    private let content: () -> Content
    private let insetContent: () -> InsetContent

    init(
        @ViewBuilder content: @escaping () -> Content,
        @ViewBuilder insetContent: @escaping () -> InsetContent
    ) {
        self.content = content
        self.insetContent = insetContent
    }

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                insetContent()
                    .anchorPreference(
                        key: InsetContentPreferenceKey.self,
                        value: .bounds
                    ) { boundsAnchor in
                        boundsAnchor
                    }
                Spacer(minLength: 0)
            }
        }
        .ignoresSafeArea(.keyboard)
        .backgroundPreferenceValue(InsetContentPreferenceKey.self) { preferences in
            GeometryReader { geometryProxy in
                preferences.map { anchor in
                    content()
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

struct SafeAreaInsetIgnoringKeyboardView_Previews: PreviewProvider {
    @State static var text = ""

    static var previews: some View {
        SafeAreaInsetIgnoringKeyboardView {
            List(0..<50) { _ in
                TextField("Title", text: $text)
            }
        } insetContent: {
            Button("Button", action: {})
                .buttonStyle(.borderedProminent)
        }

        SafeAreaInsetIgnoringKeyboardView {
            List(0..<50) { _ in
                TextField("Title", text: $text)
            }
        } insetContent: {
            Button {
            } label: {
                HStack {
                    Spacer()
                    Text("Expanding button")
                    Spacer()
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
        }
    }
}
