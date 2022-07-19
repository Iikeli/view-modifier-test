import SwiftUI
import Introspect

struct ContentView: View {
    @ObservedObject var viewModel: TestViewModel
    @StateObject var hostingViewController: HostingViewController = .init(rootViewController: nil, style: .default)

    var body: some View {
        ZStack {
            Rectangle().foregroundColor(.mint)
            VStack(alignment: .center, spacing: 25) {
                Text("Test text \(viewModel.publishedValue)")
                    .onChange(of: viewModel.publishedValue) { newValue in
                        // Change status bar color
                        if viewModel.publishedValue % 2 == 0 {
                            hostingViewController.style = .lightContent
                        } else {
                            hostingViewController.style = .darkContent
                        }

                    }
                Button("Increment") {
                    viewModel.publishedValue += 1
                }
            }
        }
        .ignoresSafeArea()
        .introspectViewController { viewController in
            let window = viewController.view.window
            guard let rootViewController = window?.rootViewController else { return }
            hostingViewController.rootViewController = rootViewController
            window?.rootViewController = hostingViewController
        }
    }
}

class TestViewModel: ObservableObject {
    @Published var publishedValue: Int

    init(publishedValue: Int) {
        self.publishedValue = publishedValue
    }
}

class HostingViewController: UIViewController, ObservableObject {
    var rootViewController: UIViewController?

    var style: UIStatusBarStyle = .default {
        didSet {
            self.rootViewController?.setNeedsStatusBarAppearanceUpdate()
        }
    }

    init(rootViewController: UIViewController?, style: UIStatusBarStyle) {
        self.rootViewController = rootViewController
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let child = rootViewController else { return }
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return style
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setNeedsStatusBarAppearanceUpdate()
    }
}
