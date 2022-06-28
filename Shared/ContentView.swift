import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: TestViewModel

    var body: some View {
        ZStack {
            Rectangle().foregroundColor(.mint)
            VStack(alignment: .center, spacing: 25) {
                Text("Test text \(viewModel.publishedValue)")
                    .onChange(of: viewModel.publishedValue) { newValue in
                        // Change status bar color
                        if viewModel.publishedValue % 2 == 0 {
                            self.body.statusBarStyle(.lightContent)
                        } else {
                            self.body.statusBarStyle(.darkContent)
                        }
                    }
                Button("Increment") {
                    viewModel.publishedValue += 1
                }
            }
        }
        .ignoresSafeArea()
        .statusBarStyle(.lightContent)
    }
}

class TestViewModel: ObservableObject {
    @Published var publishedValue: Int

    init(publishedValue: Int) {
        self.publishedValue = publishedValue
    }
}

extension View {
    /// Overrides the default status bar style with the given `UIStatusBarStyle`.
    ///
    /// - Parameters:
    ///   - style: The `UIStatusBarStyle` to be used.
    func statusBarStyle(_ style: UIStatusBarStyle) -> some View {
        return self.background(HostingWindowFinder(callback: { window in
            guard let rootViewController = window?.rootViewController else { return }
            let hostingController = HostingViewController(rootViewController: rootViewController, style: style)
            window?.rootViewController = hostingController
        }))
    }

}

fileprivate class HostingViewController: UIViewController {
    private var rootViewController: UIViewController?
    private var style: UIStatusBarStyle = .default

    init(rootViewController: UIViewController, style: UIStatusBarStyle) {
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

fileprivate struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // ...
    }
}
