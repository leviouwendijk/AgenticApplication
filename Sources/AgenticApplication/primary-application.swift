// core lib
import Agentic
import Foundation
import Frame
import Milieu

// domains
import AgenticStandard
import AgenticSessions
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
import AgenticBusiness
import AgenticScheduling
import AgenticMail
import AgenticFrame
import AgenticConfiguration
import AgenticContext
import AgenticSensitivity
import Sensitivity

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
import AgenticHost
import AgenticInterfaces
import AgenticMediaApple

/// Gateways tried, in order, when HYAI is not configured. Apple's on-device
/// model is left out: it serves only when none of these can.
private let fallbackGateways: [AgentModelGatewayIdentifier] = [
    .hyai,
    "anthropic_messages",
    .aws_bedrock,
    "openai_responses",
    .ollama,
]

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

/// The application every interface runs: the terminal (`agentic`) and the
/// macOS app install the same domains, agents, models and session services.
public struct PrimaryApplication:
    AgenticApplicationProviding,
    AgenticVoiceInputProviding,
    AgenticSessionServicesProviding,
    AgenticFrameModulesProviding
{
    public static func services(for sessionID: String?) throws -> ToolServices {
        var services = try ToolServices().inserting(
            Scheduling.ConfigurationStore.apple()
        )
        // Mail grants live for one session, starting empty: mail_request_access fills them.
        services = try services.inserting(Email.SessionAccess())
        // frame_check reads what this program decodes, not a stale file.
        services = try services.inserting(
            FrameLang.Modules(compiled: [FrameAgenticModule.module, ContextFrame.module] + frameModules)
        )
        // The home's context/ files; `.always` entries reach every agent.
        services = try services.inserting(
            Context.Store(home: AgentHomeLocator().resolveHome())
        )
        // Sensitive values reach models and session records as handles; the
        // values stay in this session's vault, in memory (AGENTIC_VAULT=keychain
        // keeps them in the Keychain for 24 hours, for resuming).
        let vault: Sensitivity.Vault
        if EnvironmentExtractor.optional("AGENTIC_VAULT") == "keychain", let sessionID {
            vault = Sensitivity.Vault(store: Sensitivity.KeychainVaultStore(account: sessionID))
        } else {
            vault = Sensitivity.Vault()
        }
        services = try services.inserting(ToolPayloadGuarding(Privacy.Guard(vault: vault)))

        // check_environment_symbol reports which names the dev env file declares, never values.
        if let devEnv = EnvironmentExtractor.optional("DEV_ENV") {
            services = try services.inserting(
                EnvironmentSymbolSources([
                    .init(label: "$DEV_ENV", url: URL(fileURLWithPath: devEnv)),
                ])
            )
        }

        let address = EnvironmentExtractor.optional("UNIFI_GATEWAY") ?? "https://unifi.lan"

        if let gateway = URL(string: address) {
            let reader = try LocalFunc.unifi.reader(gateway: gateway)
            services = try services.inserting(
                AgenticUniFi.UniFi.Runtime(reader: reader)
            )
        }

        return services
    }

    public static let frameModules: [Frame.Module] = [
        SchedulingFrame.module,
    ]

    public static let frameExamples: [AgenticFrameExample] = [
        .init(
            name: "scheduling",
            path: "domains/\(SchedulingFrame.fileName)",
            summary: "Scheduling: participants, calendars, places and defaults.",
            text: SchedulingFrame.example
        ),
    ]

    public static let voiceInputProvider: (any VoiceInputProvider)? = AppleVoiceInputProvider()

    public static let application = Agentic.application(
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
        install(Business.self)
        install(Scheduling.self)
        install(Email.self)
        install(FrameLang.self)
        install(Context.self)
        install(Privacy.self)

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
        // A purpose without a binding falls back to the default. Bindings
        // allow fallback along `fallbackGateways`, so a missing HYAI_API_KEY
        // routes to another configured provider instead of stopping the runtime.
        modelSelection(
            default: .init(
                preferredModelID: KnownModel.deepseek.v4_pro,
                gateways: fallbackGateways,
                allowsFallback: true
            ),
            purposes: [
                // Orchestrator, SwiftLang Planner: decomposition and acceptance.
                .planner: .init(
                    preferredModelID: KnownModel.deepseek.v4_pro,
                    gateways: fallbackGateways,
                    allowsFallback: true
                ),
                // Worker, SwiftLang Implementer and Renamer: bounded implementation.
                .coder: .init(
                    preferredModelID: KnownModel.deepseek.v4_pro,
                    gateways: fallbackGateways,
                    allowsFallback: true
                ),
                // Scout, SwiftLang Explorer: high-volume reading.
                .researcher: .init(
                    preferredModelID: KnownModel.deepseek.v4_pro,
                    gateways: fallbackGateways,
                    allowsFallback: true
                ),
                // Reviewers and SwiftLang Verifier: acceptance judgment; strong.
                .reviewer: .init(
                    preferredModelID: KnownModel.deepseek.v4_pro,
                    gateways: fallbackGateways,
                    allowsFallback: true
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
