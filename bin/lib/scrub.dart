bool scrubCitation(String citationSrc, String citation) {
  if (citation.contains('[...]')) {
    var citations = citation.split('[...]');
    var i = 0;
    for (i; citations.length <= i; i++) {
      if (!citationSrc.contains(citations[i])) {
        return false;
      }
    }
  } // For citations with spliced quotes, re-split them
  if (!citationSrc.contains(citation)) {
    return false;
  }

  return true; // Returning here means it has been checked and found in the document; Hooray!
}
