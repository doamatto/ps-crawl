import 'package:github/github.dart';

// Generates a GitHub issue. Run automatically by the bot in the event of a missing quote.
createIssue(
  GitHub gh,
  String product,
  String quote,
  String rubricSlug,
  String url,
) async {
  Stream<Issue> issueList = gh.issues.listAll(
    state: "open",
  );
  if (await issueList.contains(
    Issue(title: 'Citation for $product not found for $rubricSlug'),
  )) {
    return print(
      """
        $product issue for $rubricSlug already exists.
        Skipping creation of new issue.
      """,
    );
  }
  await gh.issues.create(
    IssueRequest(
      title: 'Citation for $product not found for $rubricSlug',
      body:
          'The product, [`$product`]($url), has a missing quote for the rubric item `$rubricSlug`.\n\n```\n$quote\n``` \n---\nI\'m just a bot, so I\'m not perfect. [Let us know if I\'ve made a mistake.](https://github.com/doamatto/privacyspy-bot/issues) :relaxed:',
      labels: ['product', 'help wanted', 'problem'],
    ),
  );
}
