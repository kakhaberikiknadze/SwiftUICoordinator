# SwiftUICoordinator

A Reusable Coordinator for pure *SwiftUI* project. No more need for using *UIKit* for coordinators to separate navigation logic from scenes. All you need to do is to create a subclass of a desired coordinator type (`SwiftUICoordinator`, `NavigationSwiftUICoordinator`, `TabSwiftUICoordinator`), provide a scene in a form of *SwiftUI's* `View` and coordinate to other coordinators.

# Requirements
- **XCode 14** and above
- **iOS 16** and above
- **Swift 5.7** and above
- **Swift Package Manager**

# Installation
You can either download *ZIP* and add the package locally or use **SPM**.

# SPM
- Go to your project > Package Dependencies
- Tap add
- Paste the [repo link](git@github.com:kakhaberikiknadze/SwiftUICoordinator.git)
- Choose a desired version/branch/commit. (e.g., *Up to next major* **2.0.0-beta.2**)

Or you can do it inside your `Package.swift` `dependencies` array.
e.g.
``` Swift
dependencies: [
    .package(url: "git@github.com:kakhaberikiknadze/SwiftUICoordinator.git", from: "2.0.0-beta.2")
]
```

# Example
Creating a specific coordinator is as easy as just subclassing `SwiftUICoordinator`
``` Swift
final class HomeCoordinator: SwiftUICoordinator<Void> {
    override init(
        id: String
    ) {
        super.init(id: id)
        tabItem = .init(title: "Home", image: .local(.system("house"))) // Tab item used in case it's inside tab view.
    }
    
    override func createScene() -> AnyView {
        let viewModel = HomeViewModel(coordinator: self)
        return AnyView(HomeScene(viewModel: viewModel))
    }
    
    func openAccount() -> AnyPublisher<String, Never> {
        let coordinator = AccountCoordinator(id: "[ACCOUNT_COORDINATOR " + UUID().uuidString + "]")
        return coordinate(to: coordinator, presentationStyle: .custom(.scale))
    }
}
```

If you need to return a non-`Void` result, you can change it to a desired type. e.g., `String`. Result is sent using a publisher which you can subscribe and handle it once coordinator is dismissed. Also, if the coordinator is inside navigation stack, you can use `navigationRouter: NavigationPushing` to `push` the coordinator instead of modally presenting it. `navigationRouter` will be `nil` if it's not inside navigation, so you can fallback to a modal presentation in this case.

``` Swift
final class AccountCoordinator: SwiftUICoordinator<String> {
    override func createScene() -> AnyView {
        let viewModel = AccountViewModel(coordinator: self)
        return AnyView(AccountScene(viewModel: viewModel))
    }
    
    func dismiss(result: String) {
        finish(result: result)
    }
    
    func openChat() -> AnyPublisher<Void, Never> {
        if let router = navigationRouter {
            let coordinator = ChatCoordinator(id: "[CHAT_COORDINATOR " + UUID().uuidString + "]")
            return router.push(coordinator)
        } else {
            let coordinator = ChatCoordinator(id: "[CHAT_COORDINATOR " + UUID().uuidString + "]")
            return coordinate(to: coordinator)
        }
    }
}
```

## Navigation Coordinator
To create a navigation coordinator all you need to do is to subclass `NavigationSwiftUICoordinator` instead of `SwiftUICoordinator` and your scene will automatically be wrapped inside `NavigationStack`. You won't need to push through `navigationRouter` in this case as your coordinator is a navigation router itself. So you can simply call `push` method.

``` Swift
final class HomeCoordinator: NavigationSwiftUICoordinator<Void> {
    override init(
        id: String
    ) {
        super.init(id: id)
        tabItem = .init(title: "Home", image: .local(.system("house"))) // Tab item used in case it's inside tab view.
    }
    
    override func createScene() -> AnyView {
        let viewModel = HomeViewModel(coordinator: self)
        return AnyView(HomeScene(viewModel: viewModel))
    }
    
    func openAccount() -> AnyPublisher<String, Never> {
        let coordinator = AccountCoordinator(id: "[ACCOUNT_COORDINATOR " + UUID().uuidString + "]")
        return push(coordinator)
    }
}
```

## Tab coordinator
To create a tabbed experience you need to subclass `TabSwiftUICoordinator` and provide other coordinators as tabs.

``` Swift
final class MainCoordinator: TabSwiftUICoordinator<String> {
    let homeCoordinator = HomeCoordinator(id: "HOME_COORDINATOR")
    
    let chatCoordinator = ChatCoordinator(id: "CHAT_COORDINATOR")
    
    init(id: String) {
        super.init(id: id)
        setTabs([homeCoordinator, chatCoordinator])
    }
}
```

## Start initial coordinator
Starting initial coordinator is also pretty straightforward.

``` Swift
import SwiftUI

@main
struct MyApp: App {
    private let rootScene = MainCoordinator(
        id: "[MAIN_COORDINATOR " + UUID().uuidString + "]"
    ).getRoot()
    
    var body: some Scene {
        WindowGroup {
            rootScene
        }
    }
}
```
