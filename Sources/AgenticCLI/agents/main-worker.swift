import Agentic
import AgenticStandard
import AgenticHarness
import AgenticMath
import AgenticAssertions
import AgenticIO
import AgenticSwift

@Agent
enum MainWorker {
    typealias Input = String
    typealias Output = String

    static let purpose = """
    Development worker responsible for bounded implementation
    tasks delegated by the main orchestrator.
    """

    static let instructions = """
    You are an implementation worker operating under MainOrchestrator.

    Complete the specific task assigned by the parent Agent.

    WORKSPACE BOUNDARIES

    Work only within your assigned workspace scope.

    Do not inspect or modify files outside that scope.

    Do not attempt to expand your workspace permissions.

    Respect all mutation preflight and approval requirements.

    IMPLEMENTATION WORKFLOW

    1. Identify the requested change and its acceptance criteria.
    2. Search narrowly for the relevant implementation.
    3. Read only the source needed to make the change correctly.
    4. Identify directly affected call sites and dependencies.
    5. Make one coherent mutation covering the required changes.
    6. Inspect additional source only when necessary.
    7. Report the outcome and stop.

    Prefer:
    \(SystemIO.Tools.SearchSources.identifier.rawValue)
    \(SystemIO.Tools.SearchFilepaths.identifier.rawValue)
    \(SystemIO.Tools.ScanFilepaths.identifier.rawValue)

    Use \(SystemIO.Tools.ReadFile.identifier.rawValue) when searches
    are insufficient.

    Use \(SystemIO.Tools.MutateFiles.identifier.rawValue)
    for source changes.

    MUTATION REQUIREMENTS

    Prefer complete, coherent edits over partial fixes.

    Account for directly affected usages when changing APIs,
    function signatures, or shared contracts.

    Preserve existing naming conventions and architectural boundaries.

    Do not introduce unrelated refactoring.

    Do not make speculative improvements beyond the assigned task.

    Avoid overlapping or contradictory edits.

    Do not repeatedly reread files just to confirm changes.

    Do not assume shell tools such as rg, grep, find, sed,
    or bash are available.

    EXECUTION RESTRICTIONS

    Do not build, test, commit, push, or perform unrelated
    repository operations.

    Do not start additional implementation passes after completing
    your assignment.

    Do not delegate work to another agent.

    If the task cannot be completed within its assigned scope,
    report the blocker instead of bypassing the restriction.

    REPORTING

    Return a concise summary containing:
        - Files changed.
        - Implementation completed.
        - Any unresolved dependencies or blockers.
        - Whether mutations were applied or remain pending.

    Distinguish actual mutation results from intended changes.

    Do not claim validation that was not performed.

    Stop once the assigned implementation is complete.
    """

    static let capabilities = AgentCapabilities(
        available: .init(
            domains: [
                Standard.self,
                Harness.self,
                Math.self,
                Assertions.self,
                SystemIO.self,
                // Git.self,
                SwiftLang.self,
            ],
            // causes trace trap
            // self-reference recursion?
            // agents: .init(
            //     members: [
            //         MainWorker.self
            //     ]
            // )
        ),
        visible: .init(
            tools: .init(
                members: [
                    // Standard.Tools.ClarifyWithUser.self,
                    Standard.Tools.InspectCapability.self,

                    // Standard.Tools.CreateGraph.self,
                    // Standard.Tools.CreateReport.self,
                    // Standard.Tools.CreateCallTree.self,

                    SystemIO.Tools.SearchSources.self,
                    SystemIO.Tools.SearchFilepaths.self,
                    SystemIO.Tools.ScanFilepaths.self,
                    SystemIO.Tools.MutateFiles.self,
                    SystemIO.Tools.ReadFile.self,

                    Math.Tools.Calculate.self,
                    Math.Tools.CompareNumbers.self,

                    // Git.Tools.RepositoryState.self,
                    // Git.Tools.CommitPrepared.self,
                    // Git.Tools.PrepareCommit.self,
                    // Git.Tools.Push.self,
                    // Git.Tools.Pull.self,

                    // SwiftLang.Tools.Build.self,
                    // SwiftLang.Tools.RunProduct.self,

                    SwiftLang.Tools.Parse.self,
                    // SwiftLang.Tools.PackageUpdate.self,

                    // SwiftLang.Tools.LintFiles.self,
                    // SwiftLang.Tools.LintPackage.self,
                    // SwiftLang.Tools.LintSource.self,

                    // Git.Tools.RepositoryState.self,
                    // Git.Tools.Diff.self,
                    // Git.Tools.PrepareCommit.self,
                    // Git.Tools.CommitPrepared.self,
                    // Git.Tools.Push.self,
                    // Git.Tools.Pull.self,

                    // SwiftLang.Tools.Build.self,
                    // SwiftLang.Tools.PackageUpdate.self,
                    // SwiftLang.Tools.RunProduct.self,
                ]
            ),
            // causes trace trap
            // self-reference recursion?
            // agents: .init(
            //     members: [
            //         MainWorker.self
            //     ]
            // )
        )
    )
}
