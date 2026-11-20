import SwiftUI

@main
struct ExamBPPPApp: App {
    @State private var currentScreen: AppScreen = .welcome
    
    enum AppScreen {
        case welcome
        case exam
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                switch currentScreen {
                case .welcome:
                    WelcomeView(onStartExam: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentScreen = .exam
                        }
                    })
                case .exam:
                    ExamContainerView(onExitExam: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            currentScreen = .welcome
                        }
                    })
                }
            }
            .preferredColorScheme(.light)
        }
    }
}
