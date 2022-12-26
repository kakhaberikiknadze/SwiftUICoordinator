//
//  SplitNavigationSwiftUICoordinator.swift
//  
//
//  Created by Kakhaberi Kiknadze on 18.12.22.
//

import SwiftUI
import Combine

open class SplitNavigationSwiftUICoordinator<CoordinationResult>: SwiftUICoordinator<CoordinationResult> {
    // MARK: - Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Split navigation type. `doubleColumn` or `tripleColum`.
    let splitType: SplitNavigationType
    
    /// The visibility of the leading columns in a navigation split view.
    var columnVisibility: NavigationSplitViewVisibility
    
    /// Identifier for supplementary content of navigation split view. Needed and used in `List` selection
    /// of `NavigationSplitCoordinatorView` as a workaround functionality of stacked navigation without
    /// content being inside list.
    @Published var supplementaryID: NavigationDestinationIdentifier? // When content id changes release coordinator with a previous id if present
    
    /// Identifier for detail content of navigation split view. Needed and used in `List` selection
    /// of `NavigationSplitCoordinatorView` as a workaround functionality of stacked navigation without
    /// content being inside list.
    @Published var detailID: NavigationDestinationIdentifier? // When detail id changes release coordinator with a previous id if present
    
    // Store pushed supplementary content coordinator
    private var supplementaryChild: (any NavigationScene)?
    // Store pushed detail coordinator
    private var detailChild: (any NavigationScene)?
    
    /// Placeholder view for supplementary content in navigation split view.
    /// - NOTE: Only available in triple column
    public var supplementaryPlaceholder: () -> AnyView = { EmptyView().erased() }
    
    /// Placeholder view for detail content in navigation split view.
    public var detailPlaceholder: () -> AnyView { EmptyView().erased }
    
    // MARK: - Init
    
    public init(
        id: String,
        splitType: SplitNavigationType = .doubleColumn,
        columnVisibility: NavigationSplitViewVisibility = .automatic
    ) {
        self.splitType = splitType
        self.columnVisibility = columnVisibility
        super.init(id: id)
        setupObservers()
    }
    
    // MARK: - Methods
    
    override func start() -> PresentationContext {
        NavigationSplitCoordinatorView(
            router: self,
            presentationStyle: presentationStyle,
            onCancel: { [weak self] in
                self?.cancel()
            },
            sidebar: {
                // FIXME: - Navigation stack support?
                CoordinatorView(coordinator: self) { [weak self] in
                    self?.scene
                }
            }
        )
    }
    
    public override func showDetail<T>(
        _ coordinator: SwiftUICoordinator<T>,
        fallbackPresentationStyle: FallbackPresentationStyle = .modal
    ) -> AnyPublisher<T, Never> {
        switch splitType {
        case .doubleColumn:
            return show(coordinator, context: .detail)
        case .tripleColumn:
            return _showDetail(coordinator, fallbackPresentationStyle: fallbackPresentationStyle)
        }
    }
    
    /// Show coordinator's presentation context as a supplementary content or detail depending
    /// on split navigation type.
    ///
    /// If it's a double column, context is shown as a detail. If it's a triple column, then it's shown
    /// as a supplementary content.
    ///
    /// - Note: If `showDetail` is called by `SplitNavigationSwiftUICoordinator`,  context
    /// won't be shown as a detail unless it's inside another `SplitNavigationSwiftUICoordinator` as
    /// a supplementary content. Otherwise, fallback presentation would happen (Pushing inside navigation stack / presenting
    /// modally). Use `show` method instead when you need to display the scene as a part of the split view.
    /// - Parameter coordinator: Presented coordinator.
    /// - Returns: Coordination result of the presented coordinator.
    public func show<T>(_ coordinator: SwiftUICoordinator<T>) -> AnyPublisher<T, Never> {
        let context: SplitContext = splitType == .doubleColumn ? .detail : .supplementary
        return show(coordinator, context: context)
    }
}

// MARK: - Observers

private extension SplitNavigationSwiftUICoordinator {
    func setupObservers() {
        $supplementaryID
            .filter { [weak self] in
                $0?.rawValue != self?.supplementaryChild?.id
            }
            .sink { [weak self] _ in
                self?.supplementaryChild?.cancel() // Call to send the completion
                self?.supplementaryChild = nil // FIXME: - Nil out after dismiss animation
            }
            .store(in: &cancellables)

        $detailID
            .filter { [weak self] in
                $0?.rawValue != self?.detailChild?.id
            }
            .sink { [weak self] _ in
                self?.detailChild?.cancel() // Call to send the completion
                self?.detailChild = nil // FIXME: Nil out after dismiss animation
            }
            .store(in: &cancellables)
    }
}

extension SplitNavigationSwiftUICoordinator: SplitNavigationRouting {
    func sceneForSupplementary() -> AnyView? {
        supplementaryChild?.scene ?? supplementaryPlaceholder()
    }
    
    func sceneForDetail() -> AnyView? {
        detailChild?.scene ?? detailPlaceholder()
    }
}

// MARK: - Child

extension SplitNavigationSwiftUICoordinator {
    func addChild<T>(
        _ coordinator: SwiftUICoordinator<T>,
        context: SplitContext
    ) {
        switch splitType {
        case .doubleColumn:
            addDetailChild(coordinator)
        case .tripleColumn:
            addChildInTripleColumn(coordinator, context: context)
        }
    }
    
    private func addChildInTripleColumn<T>(
        _ coordinator: SwiftUICoordinator<T>,
        context: SplitContext
    ) {
        switch context {
        case .supplementary:
            let oldChild = supplementaryChild
            supplementaryChild = coordinator.asNavigationScene()
            supplementaryID = .init(rawValue: coordinator.id)
            oldChild?.cancel()
        case .detail:
            addDetailChild(coordinator)
        }
    }
    
    private func addDetailChild<T>(_ coordinator: SwiftUICoordinator<T>) {
        let oldChild = detailChild
        detailChild = coordinator.asNavigationScene()
        detailID = .init(rawValue: coordinator.id)
        oldChild?.cancel()
    }
}

// MARK: - NavigationSplitting

extension SplitNavigationSwiftUICoordinator: NavigationSplitting {
    func show<T>(_ coordinator: SwiftUICoordinator<T>, context: SplitContext) -> AnyPublisher<T, Never> {
        switch context {
        case .supplementary:
            _addChild(coordinator, context: context)
        case .detail:
            addChild(coordinator, context: context)
        }
        
        return coordinator
            .onFinish
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.release(context: context)
            })
            .eraseToAnyPublisher()
    }
    
    /// Releases identifier for the presented context.
    /// - Parameter context: Presented context. Supplementary or detail.
    /// - Note: After it's set to `nil` `supplementaryChild` or `detailChild`
    /// (depending on the context) is cancelled and set to `nil` as well so that it's free to
    /// be deallocated.
    private func release(context: SplitContext) {
        switch context {
        case .supplementary:
            supplementaryID = nil
        case .detail:
            detailID = nil
        }
    }
}
