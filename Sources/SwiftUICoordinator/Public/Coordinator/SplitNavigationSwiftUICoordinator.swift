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
//    private var pushedScenes: [SplitType: any NavigationScene] = [:]
    
    let options: SplitNavigationOptions
    var columnVisibility: NavigationSplitViewVisibility
    @Published var contentID: NavigationDestinationIdentifier? // When content id changes release coordinator with a previous id if present
    @Published var detailID: NavigationDestinationIdentifier? // When detail id changes release coordinator with a previous id if present
    
    // Store pushed content coordinator
    // Store pushed detail coordinator
    
    private var supplementaryChild: (any NavigationScene)?
    private var detailChild: (any NavigationScene)?
    
    public var contentPlaceholder: () -> AnyView = { EmptyView().erased() }
    public var detailPlaceholder: () -> AnyView { EmptyView().erased }
    
    // MARK: - Init
    
    public init(
        id: String,
        options: SplitNavigationOptions = .doubleColumn,
        columnVisibility: NavigationSplitViewVisibility = .automatic
    ) {
        self.options = options
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
    
    func release(context: SplitContext) {
        switch context {
        case .supplementary:
            contentID = nil
        case .detail:
            detailID = nil
        }
    }
}

// MARK: - Observers

private extension SplitNavigationSwiftUICoordinator {
    func setupObservers() {
        $contentID
            .filter { [weak self] in
                $0?.rawValue != self?.supplementaryChild?.id
            }
            .sink { [weak self] _ in
                self?.supplementaryChild?.cancel()
                self?.supplementaryChild = nil
            }
            .store(in: &cancellables)
        
        $detailID
            .filter { [weak self] in
                $0?.rawValue != self?.detailChild?.id
            }
            .sink { [weak self] _ in
                self?.detailChild?.cancel()
                self?.detailChild = nil
            }
            .store(in: &cancellables)
    }
}

extension SplitNavigationSwiftUICoordinator: SplitNavigationRouting {
    func sceneForContent() -> AnyView? {
        supplementaryChild?.scene ?? contentPlaceholder()
    }
    
    func sceneForDetail() -> AnyView? {
        detailChild?.scene ?? detailPlaceholder()
    }
}

// MARK: - N

enum SplitContext {
    case supplementary // Available only in triple column. Will default to detail otherwise.
    case detail
}

protocol NavigationSplitting: AnyObject {
    func show<T>(_ coordinator: SwiftUICoordinator<T>, context: SplitContext) -> AnyPublisher<T, Never>
}

extension SplitNavigationSwiftUICoordinator {
    func addChild<T>(
        _ coordinator: SwiftUICoordinator<T>,
        context: SplitContext
    ) {
        switch options {
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
            contentID = .init(rawValue: coordinator.id)
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
    
    public func show<T>(_ coordinator: SwiftUICoordinator<T>) -> AnyPublisher<T, Never> {
        let context: SplitContext = options == .doubleColumn ? .detail : .supplementary
        return show(coordinator, context: context)
    }
}

extension SplitNavigationSwiftUICoordinator: NavigationSplitting {
    func show<T>(_ coordinator: SwiftUICoordinator<T>, context: SplitContext) -> AnyPublisher<T, Never> {
        _addChild(coordinator, context: context)
        
        return coordinator
            .onFinish
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.release(context: context)
            })
            .eraseToAnyPublisher()
    }
}
