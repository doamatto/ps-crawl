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
      search(
        product['slug'],
        gh,
        v,
      );
    }
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
    var i = 0;
    for (i; policies.length <= i; i++) {
      var resp = await http.get(policies[i]);
      if (v) {
        print('[6/8] Fetching $slug\'s policy ($i)');
      }
      if (resp.statusCode == 200) {
        var body = resp.body;
        var px = 0;
        for (px; pBody.rubric.length <= px; px++) {
          if (pBody.rubric[px].citations.isNotEmpty) {
            var cx = 0;
            for (cx; pBody.rubric[px].citations.length <= cx; cx++) {
              if (v) {
                var cite = pBody.rubric[px].citations[cx];
                print('[7/8] Scrubbing $cite for issues');
              }
              if (scrubCitation(
                body,
                pBody.rubric[px].citations[cx],
              )) {
                print("[PASS] $pBody.rubric[px].slug passed for $slug.");
              } else {
                createIssue(
                  gh,
                  slug,
                  pBody.rubric[px].citations[i],
                  pBody.sources[i],
                );
              }
            }
          } else {
            if (v) {
              var cite = pBody.rubric[px].citations[0];
              print('[7/8] Scrubbing $cite for issues');
            }
            if (scrubCitation(
              body,
              pBody.rubric[px].citations[0],
            )) {
              var rubricSlug = pBody.rubric[px].question.slug;
              print("[PASS] $rubricSlug passed for $slug.");
            } else {
              if (v) {
                var rubricSlug = pBody.rubric[px].question.slug;
                print('[8/8] Generating issue for $slug ($rubricSlug)');
              }
              createIssue(
                gh,
                slug,
                pBody.rubric[px].citations[i],
                pBody.sources[i],
              );
            }
          }
        }
      }
    }
  }
  print(
      "Looks like justice has been served, issues made, and the world saved.");
  return;
}
