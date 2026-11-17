import Agentic
import AgenticApplication
import AgenticTUI

@main
enum AgenticCLI {
    static func main() async {
        await Agentic.TUICommandLine<PrimaryApplication>.main()
    }
}
