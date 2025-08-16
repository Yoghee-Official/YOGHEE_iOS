import SwiftUI

struct HomeView: View {
    @State private var showingLoginView = false
    
    var body: some View {
        Button(action: {
            showingLoginView = true
        }) {
            Text("로그인 화면으로 이동")
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
        }
        .padding(.horizontal, 40)
        .sheet(isPresented: $showingLoginView) {
            LoginView()
        }
    }
}

#Preview {
    HomeView()
} 
