# agentic

The Agentic command line and terminal app: development agents, scheduling over
Apple Calendar, and the tools they work with.

## Install

Requires macOS 26 and a Swift 6.2 toolchain. Build and install with `sbm`
(swift-build-manager) from this directory:

```sh
git clone https://github.com/leviouwendijk/AgenticApplication.git
cd AgenticApplication
sbm
```

`sbm` builds `agentic` and installs it into `~/sbm-bin`; put that on your
`PATH`. The build signs with an Apple Development identity (`build-object.pkl`,
`--sign apple-development`); you need one in your keychain, or adjust those
arguments.

## Models

Set at least one provider key in your environment. The agents fall back along
the configured gateways, so one is enough:

- `HYAI_API_KEY`
- `ANTHROPIC_API_KEY`
- `OPENAI_API_KEY`

AWS Bedrock (through your AWS credentials) and a local Ollama are tried too.

## First run

```sh
agentic conversation
```

The first run creates the Agentic home (`~/.config/agentic`, or `~/.agentic`
where that already exists) with a `settings.frame` that lists every setting,
commented out at its default. With several agents installed it opens a picker;
`--agent <identifier>` starts one directly (`agentic diagnostics` lists them).

So your editor completes and checks `.frame` files:

```sh
agentic frame-module
```

## Scheduling

Scheduling reads `domains/scheduling.frame` in the home: who your team is,
which calendars hold whose time, working hours, places and defaults. Let the
Configurator write it with you from your real calendars:

```sh
agentic conversation --agent scheduling.agents.configurator
```

It reads your calendars, asks what they cannot tell, checks the file and shows
it before saving; saving asks for your approval and archives the previous file
to `archive/` in the home. Grant Calendar access when macOS asks.

Then schedule with:

```sh
agentic conversation --agent scheduling.agents.scheduler
```

## Mail

Mail reads the same configuration as the `email` command of the
[Mail](https://github.com/leviouwendijk/Mail) library: every `.frame` file
under `.config/mail` of every root (your own `~/.config/mail`, then the shared
roots in `~/.config/roots.frame`), at any depth. Set it up and verify it there
first (`email path` shows what is read):

```sh
email example > ~/.config/mail/accounts.frame
email check && email probe --all
```

See Mail's [configuration](https://github.com/leviouwendijk/Mail/blob/master/Documentation/configuration.md)
and [access](https://github.com/leviouwendijk/Mail/blob/master/Documentation/access.md)
documentation. In a conversation, an agent starts with no access to message
content. It sees accounts and groups, and asks for what a task needs with
`mail_request_access`, which you approve. Those grants last until the session
ends. Sending follows each account's `sending` policy and asks you per message
unless the account allows it. Passwords come from environment variables or
the keychain, so `agentic` needs the same variables as your shell.

## Configuration files

```sh
agentic example                 # what there is, and where each file goes
agentic example scheduling      # a complete scheduling.frame with made-up values
agentic example settings        # the settings.frame the first run writes
```

`settings.frame` declares the schema it is written for
(`.schema = .{ .major = 1, .minor = 0, .patch = 0 }`); the terminal header
says when yours is behind. `agentic settings-modernize` archives it and writes
the current template.

In a conversation, `:export <txt|md|html|pdf|ics>` writes the newest result to
`.agentic/artifacts/exports/` in the workspace, or to the `exports.directory`
set in `settings.frame`. PDF needs WeasyPrint (`brew install weasyprint`).
