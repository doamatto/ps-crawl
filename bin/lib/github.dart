import 'package:github/github.dart';

// Generates a GitHub issue. Run automatically by the bot in the event of a missing quote.
createIssue(GitHub gh, String product, String quote, String url) {
  gh.issues.create(
    RepositorySlug('politiwatch', 'privacyspy'),
    IssueRequest(
      title: 'Citation for $product not found',
      body:
          'The product, [$product,]($url) has a missing quote.\n\n```$quote```\n\n --- \n\n I\'m just a bot, so I\'m not perfect. Let us know if I\'ve made a mistake. :relaxed:',
      labels: ['product', 'help wanted', 'problem'],
    ),
  );
}
