import Combine
@testable import Components
@testable import Programmator
import Connection
import Nimble
import Quick
import XCTest

final class ComponentsTests: QuickSpec {
    private var bag = Set<AnyCancellable>()

    override func spec() {
        describe("Check viewmodel instruction to keyboard set conformance") {
            var viewModel: ControlPanelViewModel!
            beforeEach {
                viewModel = ControlPanelViewModel(.init(), .init(), .init())
                viewModel.bind()
            }

            context("If no instruction") {
                beforeEach {
                    viewModel.assembler.current = nil
                }
                it("primary mode expected") {
                    expect(viewModel.mode).to(equal(.primary))
                }
            }

            context("If backward instruction") {
                beforeEach {
                    viewModel.assembler.current = .forward(.init())
                }
                it("secondary mode expected") {
                    waitUntil(timeout: .seconds(10)) { done in
                        viewModel.$mode
                            .dropFirst(1)
                            .sink { mode in
                                expect(mode).to(equal(.secondary))
                                done()
                            }
                            .store(in: &self.bag)
                    }
                }
            }

            context("If cmp instruction") {
                beforeEach {
                    viewModel.assembler.current = .cmp(.init(), .init())
                }
                it("alt mode expected") {
                    waitUntil(timeout: .seconds(10)) { done in
                        viewModel.$mode
                            .dropFirst(1)
                            .sink { mode in
                                expect(mode).to(equal(.alt))
                                done()
                            }
                            .store(in: &self.bag)
                    }
                }
            }

            context("If cmp instruction, sonar but no type yet selected") {
                beforeEach {
                    let sonar: Extension.ConditionValue = .sonar(.init(), nil)
                    viewModel.assembler.current = .cmp(.init(sonar), .init())
                }
                it("cmp mode expected") {
                    waitUntil(timeout: .seconds(10)) { done in
                        viewModel.$mode
                            .dropFirst(1)
                            .sink { mode in
                                expect(mode).to(equal(.cmp))
                                done()
                            }
                            .store(in: &self.bag)
                    }
                }
            }

            context("If cmp type entered (EQ)") {
                beforeEach {
                    let sonar: Extension.ConditionValue = .sonar(.init(), .eq)
                    viewModel.assembler.current = .cmp(.init(sonar), .init())
                }
                it("secondary mode expected") {
                    waitUntil(timeout: .seconds(10)) { done in
                        viewModel.$mode
                            .dropFirst(1)
                            .sink { mode in
                                expect(mode).to(equal(.secondary))
                                done()
                            }
                            .store(in: &self.bag)
                    }
                }
            }
        }
    }
}
