import 'dart:convert' as convert;

import 'package:args/args.dart';
import 'package:github/github.dart';
import 'package:http/http.dart' as http;

import './lib/github.dart';
import './lib/scrub.dart';
import './lib/usage.dart';

void main(List<String> arguments) async {
  var parser = ArgParser();
  parser.addOption(
    'github-token',
    abbr: 'token',
    help:
        'Provide a GitHub token to make GitHub issues to the PrivacySpy repository.',
    valueHelp: 'github-token',
  );
  parser.addFlag(
    'help',
    abbr: 'h',
    help: 'See how to use the PrivacySpy bot',
  );

  var args = parser.parse(arguments);
  if (args['help'] == true) {
    return printUsage(parser);
  }

  var token = args['token'];
  var gh = GitHub(auth: Authentication.withToken(token));
  var db = Uri.https('www.privacyspy.org', '/api/v2/index.json');

  var resp = await http.get(db);
  if (resp.statusCode == 200) {
    var jsonRes = convert.jsonDecode(resp.body);
    jsonRes.slug.forEach(() => search(jsonRes.slug, gh));
    return;
  }
}

search(String slug, GitHub gh) async {
  var req = Uri.https('www.privacyspy.org', '/api/v2/products/$slug.json');
  var res = await http.get(req);
  if (res.statusCode == 200) {
    var pBody = convert.jsonDecode(res.body);
    var policies = pBody.sources.forEach((v) => v.append());
    var i = 0;
    for (i; policies.length; i++) {
      var resp = await http.get(policies[i]);
      if (resp.statusCode == 200) {
        var body = resp.body;
        var px = 0;
        for (px; pBody.rubric.length <= px; px++) {
          if (pBody.rubric[px].citations.length >= 1) {
            var cx = 0;
            for (cx; pBody.rubric[px].citations.length <= cx; cx++) {
              if (scrubCitation(body, pBody.rubric[px].citation[cx])) {
                print("[PASS] $pBody.rubric[px].slug passed for $slug.");
              } else {
                createIssue(
                    gh, slug, pBody.rubric[px].citation[i], pBody.policies[i]);
              }
            }
          } else {
            if (scrubCitation(body, pBody.rubric[px].citations[0])) {
              print("[PASS] $pBody.rubric[px].slug passed for $slug.");
            } else {
              createIssue(
                  gh, slug, pBody.rubric[px].citation[i], pBody.policies[i]);
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
