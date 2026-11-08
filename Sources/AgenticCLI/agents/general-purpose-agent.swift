import Agentic
import AgenticStandard
import AgenticHarness
import AgenticMath
import AgenticAssertions
import AgenticIO
import AgenticGit

@Agent
enum GeneralPurposeAgent {
    typealias Input = String
    typealias Output = String

    static let purpose = """
    General-purpose primary Agentic agent.
    """

    static let instructions = """
    Follow any request the user gives you.
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
            ]
        ),
        visible: .init(
            tools: .init(
                members: [
                    Standard.Tools.ClarifyWithUser.self,
                    Standard.Tools.InspectCapability.self,

                    // Standard.Tools.CreateGraph.self,
                    // Standard.Tools.CreateReport.self,

                    // SystemIO.Tools.SearchSources.self,
                    // SystemIO.Tools.SearchFilepaths.self,
                    // SystemIO.Tools.ScanFilepaths.self,
                    // SystemIO.Tools.MutateFiles.self,
                    // SystemIO.Tools.ReadFile.self,

                    // Math.Tools.Calculate.self,
                    // Math.Tools.CompareNumbers.self,

                    // Git.Tools.RepositoryState.self,
                    // Git.Tools.CommitPrepared.self,
                    // Git.Tools.PrepareCommit.self,
                    // Git.Tools.Push.self,
                    // Git.Tools.Pull.self,

                    // Git.Tools.RepositoryState.self,
                    // Git.Tools.Diff.self,
                    // Git.Tools.PrepareCommit.self,
                    // Git.Tools.CommitPrepared.self,
                    // Git.Tools.Push.self,
                    // Git.Tools.Pull.self,
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
