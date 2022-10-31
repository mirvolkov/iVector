import Nimble
@testable import Programmator
import Quick
import XCTest

final class ProgrammatorTests: QuickSpec {
    override func spec() {
        describe("Check cmp instruction extension") {
            var instruction: Instruction!
            beforeEach {
                instruction = Instruction.cmp(.init(), .init())
            }
            context("If put string value") {
                beforeEach {
                    try? instruction.setValue("test")
                }
                it("We expect text eq typed instruction") {
                    expect(self.flat(instruction)).to(equal("IF_MSG(TEST)_THEN"))
                }
            }
            context("If put int value") {
                beforeEach {
                    try? instruction.setValue(Extension.ConditionType.eq)
                    try? instruction.setValue(123)
                }
                it("We expect SON(EQ:123MM) comparison code") {
                    expect(self.flat(instruction)).to(equal("IF_SON(EQ:123MM)_THEN"))
                }
            }
            context("Sonar proximity alert 10sm") {
                beforeEach {
                    try? instruction.setValue(Extension.ConditionType.less)
                    try? instruction.setValue(100)
                }
                it("We expect SON(LESS:100MM) comparison code") {
                    expect(self.flat(instruction)).to(equal("IF_SON(LESS:100MM)_THEN"))
                }
            }
            context("Vision cat detector") {
                beforeEach {
                    try? instruction.setValue(Extension.ConditionValue.vision(.cat))
                }
                it("We expect VIS(CAT) equality code") {
                    expect(self.flat(instruction)).to(equal("IF_VIS(CAT)_THEN"))
                }
            }
            context("If see stop sign") {
                beforeEach {
                    try? instruction.setValue(Extension.ConditionValue.vision(.stopSign))
                    try? instruction.setValue(Program.init(url: .init(string: "/tmp/stop.json")!))
                }
                it("then exec stop subroutine") {
                    expect(self.flat(instruction)).to(equal("IF_VIS(STOPSIGN)_THEN_#STOP"))
                }
            }
        }
    }

    private func flat(_ instruction: Instruction) -> String {
        instruction
            .description
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "  ", with: " ")
            .replacingOccurrences(of: " ", with: "_")
            .trimmingCharacters(in: .init(charactersIn: "_"))
    }
}
