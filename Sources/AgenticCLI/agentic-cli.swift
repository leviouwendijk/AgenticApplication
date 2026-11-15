// core lib
import Agentic
import Foundation
import Milieu

// domains
import AgenticStandard
import AgenticHarness
import AgenticMath
import AgenticAssertions
import AgenticTasks
import AgenticIO
import AgenticSwift
import AgenticGit
import AgenticWeb
import AgenticAppleServices
import AgenticUniFi
import AgenticMedia
import AgenticAccounting
import AgenticPDF
import AgenticProcesses
import AgenticDevelopment

// models
import AgenticModels

// model providers
import AgenticApple
import AgenticAWS
import AgenticOllama
import AgenticHYAI
import AgenticOpenAI
import AgenticAnthropic

// runtime
import AgenticRuntime
import AgenticCommandLine
import AgenticTUI
import AgenticHost
import AgenticInterfaces
import AgenticMediaApple

private let bedrockModel = "us.anthropic.claude-opus-4-6-v1"

private let bedrockProfile = BedrockModelProfiles.profile(
    identifier: "aws_bedrock:claude_opus_4.6",
    model: bedrockModel,
    modelID: KnownModel.anthropic.`claude_opus_4.6`,
    title: "Claude Opus 4.6",
    purposes: [
        .executor,
        .planner,
        .coder,
        .researcher,
        .reviewer,
    ],
    capabilities: [
        .text,
        .tool_use,
        .streaming,
        .structured_output,
        .reasoning,
    ],
    cost: .premium
)

@main
enum AgenticCLI {
    struct Application:
        AgenticApplicationProviding,
        AgenticVoiceInputProviding,
        AgenticSessionServicesProviding
    {
        static func services(for sessionID: String?) throws -> ToolServices {
            _ = sessionID

            let address = EnvironmentExtractor.optional("UNIFI_GATEWAY") ?? "https://unifi.lan"

            guard
                let gateway = URL(string: address)
            else {
                return .init()
            }

            let reader = try LocalFunc.unifi.reader(gateway: gateway)

            return try ToolServices().inserting(
                AgenticUniFi.UniFi.Runtime(reader: reader)
            )
        }

        static let voiceInputProvider: (any VoiceInputProvider)? = AppleVoiceInputProvider()

        static let application = Agentic.application(
            "agentic",
            title: "Agentic",
            metadata: [
                "source": "agentic-cli",
            ]
        ) {
            install(Standard.self)
            install(Harness.self)
            install(Math.self)
            install(Assertions.self)
            install(Tasks.self)
            install(Accounting.self)

            install(SystemIO.self)
            install(SwiftLang.self)
            install(Git.self)
            install(Web.self)
            install(AppleServices.self)
            install(AgenticUniFi.UniFi.self)
            install(Media.self)
            install(PDF.self)
            install(Shell.self)
            install(Sessions.self)
            install(Development.self)

            install(PrimaryDeveloper.self)

            launches {
                agent(
                    PrimaryDeveloper.self,
                    // Math.Agents.Mathematician.self,
                    // Accounting.Agents.Analyst.self,
                    title: "Primary Agent"
                )
            }

            // install(PrimaryDeveloper.self)

            // AgenticApplicationComponent.launches(
            //     [
            //         agent(
            //             PrimaryDeveloper.self,
            //             title: "Primary Agent"
            //         ),
            //     ]
            // )

            // install(
            //     CoreSkillProvider()
            // )

            // Agents declare a purpose; models are bound here, per purpose.
            // A purpose without a binding falls back to the default.
            modelSelection(
                default: .init(
                    preferredModelID: KnownModel.deepseek.v4_flash,
                    gateway: .hyai
                ),
                purposes: [
                    // Orchestrator, SwiftLang Planner: decomposition and acceptance.
                    .planner: .init(
                        preferredModelID: KnownModel.deepseek.v4_pro,
                        gateways: [.hyai]
                    ),
                    // Worker, SwiftLang Implementer and Renamer: bounded implementation.
                    .coder: .init(
                        preferredModelID: KnownModel.deepseek.v4_flash,
                        gateways: [.hyai]
                    ),
                    // Scout, SwiftLang Explorer: high-volume reading; cheap and fast.
                    .researcher: .init(
                        preferredModelID: KnownModel.deepseek.v4_flash,
                        gateways: [.hyai]
                    ),
                    // Reviewers and SwiftLang Verifier: acceptance judgment; strong.
                    .reviewer: .init(
                        preferredModelID: KnownModel.deepseek.v4_pro,
                        gateways: [.hyai]
                    ),
                ],
                precedence: .default
            )

            modelProvider(
                HYAIModelProvider()
            )

            modelProvider(
                // AppleFoundationModelProfileProvider()
                AppleFoundationModelProvider()
            )

            modelProvider(
                OllamaModelProvider()
            )

            modelProvider(
                BedrockModelProvider(
                    profiles: [
                        bedrockProfile,
                    ]
                )
            )

            modelProvider(
                OpenAIModelProvider()
            )

            modelProvider(
                AnthropicModelProvider()
            )
        }
    }

    static func main() async {
        await Agentic.TUICommandLine<Application>.main()
    }
}
