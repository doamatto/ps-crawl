package main

import (
	"context"
	"encoding/json"
	"flag"
	"log"
	"os"
	"regexp"
	"strings"

	"github.com/google/go-github/v46/github"
	"golang.org/x/oauth2"
)

var runDry bool
var getHelp bool
var ghToken string

const userAgent := "maatt DOT fr/ps-crawl"
const indexUrl := "https://www.privacyspy.org/api/v2/index.json"
const productUrl := "https://www.privacyspy.org/api/v2/products/"
const repoOwner := "politiwatch"
const repoName := "privacyspy"

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
			req, err = http.NewRequest("GET", policy, nil)
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
								log.Println("Found issue in %v. Creating issue...", product.name)
								createIssue(product.name, citationOrig, rubricItem.question.slug, policy)
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

// Generate issue using GitHub API
//
// It makes more sense to use the official API in this case becuase
// implementing the REST API would not only take a significant amount
// of time, but also require serious maintainership. This crawler
// should be able to be "set it and forget it."
func createIssue(product string, citation string, rubricSlug string, url string) bool {
	if dryRun { return false }

	// Build GitHub API connection
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: ghToken})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	// Check if issue already exists
	issues, _, err := client.IssuesService.ListByRepo(ctx, repoOwner, repoName, {
		State: "open"
	})
	issueName := strings.Join([]{"Citation for",product,"not found for",rubricSlug}, " ")
	i := false
	for _, v := range issues {
		if issueName == v.Title {
			i = true
		}
	}

	// Build issue
	if !i {
		issue, _, err := client.IssuesService.Create(ctx, repoOwner, repoName, &github.IssueRequest{
			Title: issueName,
			Body: "",
			Labels: [""],
		})
		if err != nil {
			log.Panicln("Could not create issue. Halting program to prevent rate-limiting.")
			return os.Exit(1)
		}
		log.Println("Issue created. See %v.", issue.URL)
	} else {
		log.Println("Issue already exists. Skipping creation of issue.")
	}
}
