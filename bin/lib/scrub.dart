bool scrubCitation(String citationSrc, String citation) {
  List<dynamic> citations = splitCitation(citation);
  for (var citation in citations) {
    citation = citation.replaceAll('[...]', '');
    citation = citation.replaceAll('[â�¦]', '');
    citation = citation.replaceAll(
      RegExp(
        'r(?:\\")',
      ),
      '',
    ); // TODO: integrate into new splitter
    citation = citation.replaceAll("&nbsp;", " ");

    if (!citationSrc.contains(citation)) {
      return false;
    }
  }

  return true; // Returning here means it has been checked and found in the document; Hooray!
}

List<dynamic> splitCitation(String original) {
  List<dynamic> citations = [];
  if (original.contains('[...]')) {
    citations = original.split('[...]');
    return citations;
  } else if (original.contains(RegExp('r(?:\\n){1,}'))) {
    citations = original.split(RegExp('r(?:\\n){1,}'));
    return citations;
  } else {
    citations.add(original);
    return citations;
  }
}
