import 'package:github/github.dart';

// Generates a GitHub issue. Run automatically by the bot in the event of a missing quote.
createIssue(
  GitHub gh,
  String product,
  String quote,
  String rubricSlug,
  String url,
) {
  gh.issues.create(
    RepositorySlug('politiwatch', 'privacyspy'),
    IssueRequest(
      title: 'Citation for $product not found for $rubricSlug',
      body:
          'The product, [`$product`,]($url) has a missing quote for the rubric item `$rubricSlug`.\n\n`$quote` \n--- I\'m just a bot, so I\'m not perfect. [Let us know if I\'ve made a mistake.](https://github.com/doamatto/privacyspy-bot/issues) :relaxed:',
      labels: ['product', 'help wanted', 'problem'],
    ),
  );
}
