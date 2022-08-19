# PrivacySpy Bot

## Usage
Using this bot is incredibly easy. After building it (see next section or click [here](#building)), you can run the bot by doing:
```sh
$ GITHUB_TOKEN=<github-token> ./ps-crawler
```

You can get a GitHub (Personal) token [here](https://github.com/settings/tokens). Ensure that you give your token the `public_repo` scope, so that it can make issues. This bot is made on purpose not to be too expandable, as there is little to no need. See [the future ideas](#future-ideas) for any ideas in the future of how this may change.

## Building
1. Install [Go](https://golang.org/dl)
2. Build binaries (`go build`)

## Future ideas
- [ ] Typings for expected responses to allow both null-safety and piece of mind
- [ ] Disable push to GitHub to show just problems (dry-run)
- [ ] Ensure rendering of hydrated content works fine
  - [ ] JSP pages like [Mailfence](https://mailfence.com/en/privacy.jsp)
- Ensure weird text (that one apostrophe that is an apostrophe but isn't (`(?:")|(?:”)|(?:“)|(?:‟)`)) doesn't break things
- [ ] Add handling for more seperations
- [ ] Fix Markdown links ([#121 of test repo](https://github.com/doamatto/privacyspy/issues/121))
  - [ ] Fix HTML links ([#176 of test repo](https://github.com/doamatto/privacyspy/issues/176))

## Acknowledgments
This project is licensed under the GNU General Public License version 3.0. You can see a copy of it in the `LICENSE` file in the root of this repository.

PrivacySpy is an open-souce initiative maintained by [Miles McCain](https://miles.land), [Igor Barakaiev](https://igor.fyi), and the [Politiwatch](https://politiwatch.org) team. Nothing on PrivacySpy is legal advice.

I hope to make this an official Politiwatch tool, but until then, it has no affiliation with Politiwatch, the Politiwatch team, or PrivacySpy. 
