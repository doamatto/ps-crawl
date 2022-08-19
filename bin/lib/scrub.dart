bool scrubCitation(String citationSrc, String citation) {
  for (var citation in citations) {

    if (!citationSrc.contains(citation)) {
      return false;
    }
  }

  return true; // Returning here means it has been checked and found in the document; Hooray!
}

