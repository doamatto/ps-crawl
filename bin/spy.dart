import 'dart:convert' as convert;

import 'package:args/args.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;

import './lib/github.dart';
import './lib/product.dart';
import './lib/scrub.dart';
import './lib/usage.dart';

void main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption(
    'github-token',
    abbr: 't',
    help:
        'Provide a GitHub token to make GitHub issues to the PrivacySpy repository.',
    valueHelp: 'github-token',
  );
  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'See how to use the PrivacySpy bot',
  );
  parser.addFlag(
    'verbose',
    abbr: 'v',
    help:
        'Good for CIs and development (removes the silence of nothing in the console while it works).',
  );

  var args = parser.parse(arguments);
  if (args['help'] == true) {
    return printUsage(parser);
  }
  if (args['github-token'] == '') {
    return printUsage(parser);
  }

  var token = args['github-token'];
  var v = args['verbose'];
  var gh = GitHub(
    auth: Authentication.withToken(token),
  );
  if (v) {
    print('[1/8] Authenticating with GitHub');
  }
  var db = Uri.https('www.privacyspy.org', '/api/v2/index.json');

  var resp = await http.get(db);
  if (v) {
    print('[2/8] Fetching product index');
  }
  if (resp.statusCode == 200) {
    var jsonRes = await convert.jsonDecode(resp.body);
    if (v) {
      print('[3/8] Parsing product index into JSON');
    }
    for (var product in jsonRes) {
      await search(
        product['slug'],
        gh,
        v,
      );
    }
    print(
      "Looks like justice has been served, issues made, and the world saved.",
    );
    return;
  } else {
    print(
      "It appears there was troubles connecting to the Internet. Make sure you can reach PrivacySpy's website (https://privacyspy.org/api).",
    );
    return;
  }
}

search(String slug, GitHub gh, bool v) async {
  var req = Uri.https('www.privacyspy.org', '/api/v2/products/$slug.json');
  var res = await http.get(req);
  if (v) {
    print('[4/8] Fetching $slug\'s JSON');
  }
  if (res.statusCode == 200) {
    var pBody = Product.fromJson(convert.jsonDecode(res.body));
    if (v) {
      print('[5/8] Parsing $slug\'s JSON');
    }
    var policies = pBody.sources;
    for (var policy in policies) {
      var url = Uri.parse(policy);
      var resp = await http.get(url);
      if (v) {
        print('[6/8] Fetching $slug\'s policy ($policy)');
      }
      if (resp.statusCode == 200) {
        var body = resp.body;
        for (var rubricItem in pBody.rubric) {
          for (var citation in rubricItem['citations']) {
            if (scrubCitation(body, citation)) {
              if (v) {
                var policySlug = rubricItem['question']['slug'];
                print('[PASS] $slug for $policySlug');
            }
          } else {
            if (v) {
                var policySlug = rubricItem['question']['slug'];
                print('[FAIL] $slug for $policySlug');
              }
              createIssue(
                gh,
                slug,
                citation,
                policy,
              );
            }
          }
        }
      }
    }
  }
  return;
}
