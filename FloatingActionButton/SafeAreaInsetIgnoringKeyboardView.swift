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

struct SafeAreaInsetIgnoringKeyboardView<Content: View, InsetContent: View, BackgroundContent: View>: View {
    private let content: Content
    private let insetContent: InsetContent
    private let backgroundContent: BackgroundContent

    init(
        content: Content,
        @ViewBuilder inset insetContentBuilder: () -> InsetContent,
        @ViewBuilder background backgroundContentBuilder: () -> BackgroundContent = { EmptyView() }
    ) {
        self.content = content
        self.insetContent = insetContentBuilder()
        self.backgroundContent = backgroundContentBuilder()
    }

    var body: some View {
        VStack {
            Spacer(minLength: 0)
            HStack(spacing: 0) {
                Spacer(minLength: 0)
                insetContent
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
                    VStack {
                        Spacer()
                        backgroundContent
                            .frame(height: geometryProxy[anchor].height + geometryProxy.safeAreaInsets.bottom)
                    }
                    .ignoresSafeArea(edges: .bottom)
                }
            }
            .ignoresSafeArea(.keyboard)
        }
        .backgroundPreferenceValue(InsetContentPreferenceKey.self) { preferences in
            GeometryReader { geometryProxy in
                preferences.map { anchor in
                    content
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

struct SafeAreaInsetIgnoringKeyboard<InsetContent: View, BackgroundContent: View>: ViewModifier {
    private let insetContentBuilder: () -> InsetContent
    private let backgroundContentBuilder: () -> BackgroundContent

    init(
        @ViewBuilder _ insetContentBuilder: @escaping () -> InsetContent,
        @ViewBuilder background backgroundContentBuilder: @escaping () -> BackgroundContent = { EmptyView() }
    ) {
        self.insetContentBuilder = insetContentBuilder
        self.backgroundContentBuilder = backgroundContentBuilder
    }

    func body(content: Content) -> some View {
        SafeAreaInsetIgnoringKeyboardView(
            content: content,
            inset: insetContentBuilder,
            background: backgroundContentBuilder
        )
    }
}

extension View {
    func safeAreaInsetIgnoringKeyboard<InsetContent: View, BackgroundContent: View>(
        @ViewBuilder _ insetContentBuilder: @escaping () -> InsetContent,
        @ViewBuilder background backgroundContentBuilder: @escaping () -> BackgroundContent = { EmptyView() }
    ) -> some View {
        modifier(
            SafeAreaInsetIgnoringKeyboard(
                insetContentBuilder,
                background: backgroundContentBuilder
            )
        )
    }
}

struct SafeAreaInsetIgnoringKeyboardView_Previews: PreviewProvider {
    @State static var text = ""

    static var previews: some View {
        SafeAreaInsetIgnoringKeyboardView(content:
            List(0..<50) { _ in
                TextField("Title", text: $text)
            }
        ) {
            Button("Button", action: {})
                .buttonStyle(.borderedProminent)
        }
        .previewDisplayName("View with hugging button")

        SafeAreaInsetIgnoringKeyboardView(content:
            List(0..<50) { _ in
                TextField("Title", text: $text)
            }
        ) {
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
        .previewDisplayName("View with expanding button")

        List(0..<50) { _ in
            TextField("Title", text: $text)
        }
        .safeAreaInsetIgnoringKeyboard {
            Button("Button", action: {})
                .buttonStyle(.borderedProminent)
        }
        .previewDisplayName("View modifier with hugging button")

        List(0..<50) { _ in
            TextField("Title", text: $text)
        }
        .safeAreaInsetIgnoringKeyboard {
            Button("Button", action: {})
                .buttonStyle(.borderedProminent)
                .padding(20)
        } background: {
            Color.white
                .cornerRadius(24)
                .shadow(radius: 5)
        }
        .previewDisplayName("View modifier with background")
    }
}
