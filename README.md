# PrivacySpy Bot

## Usage
Using this bot is incredibly easy. After building it (see next section or click [here](#building)), you can run the bot by doing:
```sh
$ ./bin/spy --github-token=<github-token>
```

You can get a GitHub (Personal) token [here](https://github.com/settings/tokens). Ensure that you give your token the `public_repo` scope, so that it can make issues. This bot is made on purpose not to be too expandable, as there is little to no need. See [the future ideas](#future-ideas) for any ideas in the future of how this may change.

## Building
1. Install [Dart](https://dart.dev)
2. Fetch dependencies (`dart pub get`)

To build binaries, use `dart compile exe bin/spy.dart`. Regardless of platform, the `exe` parameter will compile a binary for your OS (Linux, macOS, Windows, et al).

## Future ideas
- [ ] Allowing custom PrivacySpy instances (defaults to official)
- [ ] Typings for expected responses to allow both null-safety and piece of mind
- [ ] Allowing custom PrivacySpy forks (defaults to official)

## Acknowledgments
This project is licensed under the GNU General Public License version 3.0. You can see a copy of it in the `LICENSE` file in the root of this repository.

PrivacySpy is an open-souce initiative maintained by [Miles McCain](https://miles.land), [Igor Barakaiev](https://igor.fyi), and the [Politiwatch](https://politiwatch.org) team. Nothing on PrivacySpy is legal advice.