import Agentic
import AgenticGeneral
import Schema

/// The application's default agent: the general-purpose agent with every
/// installed domain available, discovered on demand.
@Agent
enum Generic: AgentFork {
    typealias Base = General.Agents.GeneralPurpose

    static let fork = AgentDerivation(
        available: .domains(PrimaryApplication.installedDomains)
    )
}
