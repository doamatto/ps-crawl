search(String slug, GitHub gh, bool v, bool ciMode, bool onlyFail) async {
    for (var policy in policies) {
      if (resp.statusCode == 200) {
        var body = resp.body;
        for (var rubricItem in pBody.rubric) {
          for (var citation in rubricItem['citations']) {
            if (scrubCitation(body, citation)) {
              if (v == true && onlyFail == false) {
                var policySlug = rubricItem['question']['slug'];
                print('[PASS] $slug for $policySlug');
              }
            } else {
              if (v) {
                var policySlug = rubricItem['question']['slug'];
                print('[FAIL] $slug for $policySlug');
              }
              if (ciMode == false) {
                createIssue(
                  gh,
                  slug,
                  citation,
                  rubricItem['question']['slug'],
                  policy,
                );
              }
            }
          }
        }
      }
    }
  }
  return;
}
