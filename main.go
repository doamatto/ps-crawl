package main

import (
	"encoding/json"
	"flag"
	"log"
	"os"
	"regexp"
	"strings"
)

var runDry bool
var getHelp bool
var ghToken string

const userAgent := "maatt DOT fr/ps-crawl"
const indexUrl := "https://www.privacyspy.org/api/v2/index.json"
const productUrl := "https://www.privacyspy.org/api/v2/products/"

func init() {
	// Fetch dry-run flag
	const (
		usage = "Scan sites without reporting to GitHub. Good for testing."
	)
	flag.BoolVar(&runDry, "dry-run", false, usage)
	flag.BoolVar(&runDry, "n", false, usage+" (shorthand)")

	// Fetch GitHub token
	ghToken := os.Getenv("GITHUB_TOKEN")
	if ghToken !== "" {
		log.Fatalln("GITHUB_TOKEN is either not set or blank.")
	}
}

func main() {
	flag.Parse()
	client := &http.Client{}

	// Test connection to GitHub with token
	if !runDry {
		log.Println("Testing GitHub token...")
		req, err := http.NewRequest("GET", "https://api.github.com/emojis", nil)
		if err != nil {
			log.Fatalln(err)
		}
		req.header.Set("User-Agent", "maatt DOT fr/ps-crawl")
		req.header.Set("Authorization", strings.Join([]{"token",ghToken}, " "))
		req.header.Set("Accept", "application/vnd.github+json")
		res, err := client.Do(req)
		if err != nil {
			log.Panicln("Either GitHub is down or the GITHUB_TOKEN is invalid.")
			return os.Exit(1)
		}
		log.Println("GitHub token appears to be valid.")
		res.Body.Close()
	}

	// Fetch index of products from api
	log.Println("Fetching product index: %v", indexUrl)
	req, err = http.NewRequest("GET", indexUrl, nil)
	if err != nil {
		log.Fatalln(err)
	}
	req.header.Set("User-Agent", userAgent)

	res, err = client.Do(req)
	if err != nil {
		log.Fatalln(err)
	}
	defer res.Body.Close()
	var index []Index
	err := json.Unmarshal(res.Body, &index)
	if err != nil {
		log.Panicln("Couldn't parse data from product index.")
		return os.Exit(1)
	}
	res.Body.Close()

	for _, v := range index {
		slug := v.slug

		// Fetch product data
		productUrl := strings.Join([]{productUrl,slug,".json"}, "")
		req, err = http.NewRequest("GET", productUrl, nil)
		req.header.Set("User-Agent", "maatt DOT fr/ps-crawl")
		res, err := client.Do(req)
		if err != nil {
			log.Panicln("Can't access product data.")
			return os.Exit(1)
		}
		defer res.Body.Close()
		var product Product
		err := json.Unmarshal(res.Body, &index)
		if err != nil {
			log.Panicln("Couldn't parse data from product data.")
			return os.Exit(1)
		}
		res.Body.Close()

		// Parse product sources
		policies := product.sources;
		for _, policy := range policies {
			req, err = http.NeqRequest("GET", policy, nil)
			req.header.Set("User-Agent", "maatt DOT fr/ps-crawl")
			res, err := client.Do(req)
			defer res.Body.Close()
			if err != nil {
				log.Panicln("Can't access product website. Skipping...")
				res.Body.Close()
			} else {
				body := io.ReadAll(res.Body)

				for _, rubricItem := range product.rubric {
					// Sanitise and check for matches
					for _, citationOrig := range rubricItem.citations {
						re := regexp.MustCompile(`(?:\\n){1,}`)
						if strings.Contains(citationOrig, "[...]") {
							citations := strings.Split(citationOrig, "[...]")
						} else if re.MatchString(citationOrig) {
							citations := re.Split(citationOrig, -1)
						} else {
							citations := []{citation}
						}
						for _, citation := range citations {
							citation := strings.ReplaceAll(citationOrig, "[...]", "")
							citation = strings.ReplaceAll(citation, "[â�¦]", "")
							citation = strings.ReplaceAll(citation, "&nbsp;", "")
							re = regexp.MustCompile(`?:\\"`)
							citation = re.ReplaceAll(citation, "")

							// Check if citation is in source
							if (!strings.Contains(body, citation)) {
								// return false
							} else {
								// return true
							}
						}
					}
				}
				res.Body.Close()
			}
		}
	}
	log.Println("Looks like justice has been served, issues made, and the world saved.")
}
