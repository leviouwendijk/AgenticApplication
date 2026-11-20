import Agentic
import AgenticDevelopment
import AgenticIO
import AgenticMath
import AgenticSessions
import AgenticStandard
import AgenticSwift
import Schema

/// The Development agent in this application: Swift tooling installed and
/// visible, plus this application's workspace notes.
@Agent
enum Developer: AgentFork {
    typealias Base = Development.Agents.Developer

    static let fork = AgentDerivation(
        instructions: .appending(Instructions(notes)),
        available: .domains(SwiftLang.self),
        visible: .tools(
            Standard.Tools.CreateGraph.self,
            Standard.Tools.CreateReport.self,
            Standard.Tools.CreateCallTree.self,

            Math.Tools.Calculate.self,
            Math.Tools.CompareNumbers.self,

            SwiftLang.Tools.Build.self,
            SwiftLang.Tools.RunProduct.self,
            SwiftLang.Tools.RunTests.self,
            SwiftLang.Tools.RunBenchmarks.self,
            SwiftLang.Tools.Parse.self,
            SwiftLang.Tools.PackageUpdate.self
        )
    )

    private static let notes = """
    WORKSPACE

    Work directly in the active Agentic workspace. Find text in past \
    sessions' transcripts with \(Sessions.Tools.Search.identifier.rawValue). \
    Use \(SystemIO.Tools.ClipboardRead.identifier.rawValue) and \
    \(SystemIO.Tools.ClipboardWrite.identifier.rawValue) only when asked.
    """
}
