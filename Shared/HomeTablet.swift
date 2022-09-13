import SwiftUI

struct HomeTablet: View {
    var body: some View {
        NavigationView {
            ControlPanel()
                .frame(width: 320)
                .navigationTitle("Navigation")
                .navigationBarTitleDisplayMode(.inline)
            DetailPanel()
                .navigationTitle("Navigation")
                .navigationBarHidden(false)
                .navigationViewStyle(.stack)
                .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            if #available(iOS 15.0, *) {
                let navigationBarAppearance = UINavigationBarAppearance()
                navigationBarAppearance.backgroundColor = .systemBackground
                UINavigationBar.appearance().standardAppearance = navigationBarAppearance
                UINavigationBar.appearance().compactAppearance = navigationBarAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            }
        }
        .ignoresSafeArea()
    }
}
