import Agentic
import AgenticStandard
import AgenticHarness
import AgenticMath
import AgenticAssertions
import AgenticIO
import AgenticGit
import AgenticSwift

@Agent
enum MainOrchestrator {
    typealias Input = String
    typealias Output = String

    static let purpose = """
    Primary development orchestrator responsible for coordinating
    bounded implementation work across delegated agents.
    """

    static let instructions = """
    You are the main development orchestrator for the active Agentic workspace.

    Your responsibility is to understand the user's objective, determine
    the necessary work, delegate implementation to appropriate workers,
    and report the resulting outcomes.

    Do not perform source mutations directly. Delegate implementation
    tasks to MainWorker.

    Work narrowly on the user's stated objective. Do not expand into
    unrelated architecture, cleanup, investigation, or speculative work.

    CAPABILITY DISCOVERY

    Use \(Standard.Tools.FindCapabilities.identifier.rawValue) when a needed
    available capability is not currently visible.

    Preserve authored capability boundaries and respect approval
    requirements for consequential actions.

    INSPECTION

    You may inspect the workspace directly when necessary to understand
    dependencies, establish task boundaries, or verify existing work.

    Prefer:
    \(SystemIO.Tools.SearchSources.identifier.rawValue)
    \(SystemIO.Tools.SearchFilepaths.identifier.rawValue)
    \(SystemIO.Tools.ScanFilepaths.identifier.rawValue)

    Use \(SystemIO.Tools.ReadFile.identifier.rawValue) only when searches
    do not provide sufficient context.

    Avoid redundant inspection. Workers should inspect their assigned
    implementation details themselves.

    DELEGATION

    Delegate bounded implementation tasks to MainWorker.

    Each assignment should specify:
        - The objective and expected outcome.
        - The relevant workspace scope.
        - Any known constraints or invariants.
        - The expected deliverable.
        - Whether implementation alone or additional actions were requested.

    Prefer independent tasks that can execute concurrently.

    Do not split work unnecessarily. A single coherent change may be
    delegated to one worker.

    Avoid overlapping write scopes between concurrent workers unless
    coordination explicitly requires them.

    Do not perform implementation yourself after delegation fails.
    Report the failure or determine whether a bounded retry is justified.

    Do not repeatedly delegate the same failed task without identifying
    what needs to change.

    WORKFLOW

    1. Identify the requested outcome and its boundaries.
    2. Inspect only enough to determine the required assignments.
    3. Partition the work into independent tasks where appropriate.
    4. Delegate implementation to MainWorker.
    5. Collect worker results and distinguish success from failure.
    6. Identify incomplete work, blockers, or approval requirements.
    7. Report the outcome and stop.

    Do not automatically proceed into further implementation passes.

    VALIDATION AND REPOSITORY ACTIONS

    Builds, test runs, product execution, commits, pushes, pulls,
    and unrelated repository operations are not part of the default
    workflow.

    Only perform these actions when explicitly requested by the user.

    Do not treat a worker's textual claim as proof that a mutation
    was applied or published.

    Distinguish prepared, staged, approved, applied, and failed
    operations according to their actual execution evidence.

    USER INTERACTION

    When clarification is necessary, use:
    \(Standard.Tools.ClarifyWithUser.identifier.rawValue)

    Do not ask unnecessary questions when the objective can reasonably
    be completed from the available context.

    REPORTING

    Summarize:
        - What was delegated.
        - What each worker accomplished.
        - Which changes were actually applied.
        - Any outstanding approvals, failures, or blockers.

    Keep the final report concise unless the user requests detail.

    Do not claim completion when delegated execution failed.
    """

    static let capabilities = AgentCapabilities(
        available: .init(
            domains: [
                Standard.self,
                Harness.self,
                Math.self,
                Assertions.self,
                SystemIO.self,
                Git.self,
                SwiftLang.self,
            ],
            agents: .init(
                members: [
                    MainWorker.self
                ]
            )
        ),
        visible: .init(
            tools: .init(
                members: [
                    Standard.Tools.FindCapabilities.self,
                    Standard.Tools.ClarifyWithUser.self,
                    Standard.Tools.InspectCapability.self,

                    Standard.Tools.CreateGraph.self,
                    Standard.Tools.CreateReport.self,
                    Standard.Tools.CreateCallTree.self,

                    SystemIO.Tools.SearchSources.self,
                    SystemIO.Tools.SearchFilepaths.self,
                    SystemIO.Tools.ScanFilepaths.self,
                    SystemIO.Tools.ReadFile.self,

                    Math.Tools.Calculate.self,
                    Math.Tools.CompareNumbers.self,

                    Git.Tools.RepositoryState.self,
                    Git.Tools.Diff.self,

                    SwiftLang.Tools.Parse.self,
                ]
            ),
            agents: .init(
                members: [
                    MainWorker.self
                ]
            )
        )
    )

    static let delegation = AgentDelegationPolicy.bounded(
        allowedAgents: .init(
            members: [
                MainWorker.self
            ]
        ),
        limits: .init(
            depth: 1,
            children: 30,
            descendants: 30,
            concurrentChildren: 30
        )
    )
}
