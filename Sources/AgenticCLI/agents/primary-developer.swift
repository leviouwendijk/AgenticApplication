import Agentic
import AgenticStandard
import AgenticHarness
import AgenticMath
import AgenticAssertions
import AgenticIO
import AgenticGit
import AgenticSwift

@Agent
enum PrimaryDeveloper {
    typealias Input = String
    typealias Output = String

    static let purpose = """
    General-purpose primary Agentic development agent.
    """

    static let instructions = """
    Work directly in the active Agentic workspace.
    Inspect narrowly before mutating and prefer deterministic tools over speculative reasoning.
    Use \(Standard.Tools.FindCapabilities.identifier.rawValue) when a needed available capability is not currently visible.
    Preserve the authored capability boundary and respect approval requirements for consequential actions.

    Use these tools for IO operations:
    \(SystemIO.Tools.SearchSources.identifier.rawValue) (lighter than full file reads, especially useful for range or symbol lookups)
    \(SystemIO.Tools.SearchFilepaths.identifier.rawValue)
    \(SystemIO.Tools.ScanFilepaths.identifier.rawValue) 
    \(SystemIO.Tools.MutateFiles.identifier.rawValue) (edit tool)
    \(SystemIO.Tools.ReadFile.identifier.rawValue) (use when search is inadequate, but avoid redundant full file reads)

    If you need to clarify anything with me, use:
    \(Standard.Tools.ClarifyWithUser.identifier.rawValue)

    These are available, but not fully schema visible by default (use \(Standard.Tools.FindCapabilities.identifier.rawValue) to make them visible):
    \(Git.Tools.RepositoryState.identifier.rawValue)
    \(Git.Tools.Diff.identifier.rawValue)
    \(Git.Tools.PrepareCommit.identifier.rawValue)
    \(Git.Tools.CommitPrepared.identifier.rawValue)
    \(Git.Tools.Push.identifier.rawValue)
    \(Git.Tools.Pull.identifier.rawValue)

    \(SwiftLang.Tools.Build.identifier.rawValue)
    \(SwiftLang.Tools.PackageUpdate.identifier.rawValue)
    \(SwiftLang.Tools.RunProduct.identifier.rawValue)

    Additionally, for clipboard operations, when I request it:
    \(SystemIO.Tools.ClipboardRead.identifier.rawValue) 
    \(SystemIO.Tools.ClipboardWrite.identifier.rawValue) 

    Default workflow:
        Work narrowly on the requested task. Do not expand into unrelated architecture, cleanup, investigation, or speculative improvements.

        1. Search only enough to locate the relevant implementation and usages.
        2. Read only the files/ranges needed to understand the intended edit.
        3. Make the smallest coherent mutation that satisfies the request.
        4. Search again only when needed to catch directly related remaining sites.
        5. Stop once the requested source change is complete.
        6. Avoid repeated read_file calls just to confirm, bloating the context window expensively.

    Do not keep investigating merely because adjacent issues or possible improvements exist. Do not broaden the objective without explicit instruction.

    Do not repeatedly reread/search the same material unless new information makes it necessary.

    Do not run for an arbitrary amount of time trying to make the repository generally better. Optimize for completing the stated pass with the minimum necessary inspection and edits.

    Do not assume shell tools such as rg, grep, find, sed, bash, etc. are available.
    Use the source tools listed above.

    Builds, test/product runs, git operations, commits, pushes, and other validation or repository actions are NOT part of the default workflow.

    After making the requested source changes, stop and report what changed.

    I will explicitly tell you when I want you to:
        - build;
        - run tests/products;
        - inspect diffs further;
        - commit;
        - push;
        - continue into another pass.
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
            ]
        ),
        visible: .init(
            tools: .init(
                members: [
                    Standard.Tools.ClarifyWithUser.self,
                    Standard.Tools.InspectCapability.self,

                    Standard.Tools.CreateGraph.self,
                    Standard.Tools.CreateReport.self,
                    Standard.Tools.CreateCallTree.self,

                    SystemIO.Tools.SearchSources.self,
                    SystemIO.Tools.SearchFilepaths.self,
                    SystemIO.Tools.ScanFilepaths.self,
                    SystemIO.Tools.MutateFiles.self,
                    SystemIO.Tools.ReadFile.self,

                    Math.Tools.Calculate.self,
                    Math.Tools.CompareNumbers.self,

                    Git.Tools.RepositoryState.self,
                    Git.Tools.CommitPrepared.self,
                    Git.Tools.PrepareCommit.self,
                    Git.Tools.Push.self,
                    Git.Tools.Pull.self,

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
            )
        )
    )

    static let modelSelection = AgentModelSelection(
        purpose: .executor,
        preferences: .init(
            preferredProfileIdentifier: .hyai_auto,
            gateway: .hyai
        )
    )
}
