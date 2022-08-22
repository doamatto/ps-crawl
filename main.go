package main

import (
	"context"
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"regexp"
	"strings"

	"github.com/google/go-github/v46/github"
	"golang.org/x/oauth2"
)

var runDry bool
var getHelp bool
var ghToken string

const userAgent string = "maatt DOT fr/ps-crawl"
const indexUrl string = "https://www.privacyspy.org/api/v2/index.json"
const productUrl string = "https://www.privacyspy.org/api/v2/products/"
const repoOwner string = "politiwatch"
const repoName string = "privacyspy"

func init() {
	// Fetch dry-run flag
	const (
		usage = "Scan sites without reporting to GitHub. Good for testing."
	)
	flag.BoolVar(&runDry, "dry-run", false, usage)
	flag.BoolVar(&runDry, "n", false, usage+" (shorthand)")
}

func main() {
	flag.Parse()
	client := &http.Client{}

	// Fetch GitHub token
	if !runDry {
		ghToken := os.Getenv("GITHUB_TOKEN")
		if ghToken != "" {
			log.Fatalln("GITHUB_TOKEN is either not set or blank.")
		}
	}

	// Test connection to GitHub with token
	if !runDry {
		log.Println("Testing GitHub token...")
		req, err := http.NewRequest("GET", "https://api.github.com/emojis", nil)
		if err != nil {
			log.Fatalln(err)
		}
		req.Header.Set("User-Agent", "maatt DOT fr/ps-crawl")
		req.Header.Set("Authorization", strings.Join([]string{"token",ghToken}, " "))
		req.Header.Set("Accept", "application/vnd.github+json")
		res, err := client.Do(req)
		if err != nil {
			log.Panicln("Either GitHub is down or the GITHUB_TOKEN is invalid.")
			log.Panicln(err)
			os.Exit(1)
		}
		log.Println("GitHub token appears to be valid.")
		res.Body.Close()
	}

	// Fetch index of products from api
	log.Println("Fetching product index: ", indexUrl)
	req, err := http.NewRequest("GET", indexUrl, nil)
	if err != nil {
		log.Fatalln(err)
	}
	req.Header.Set("User-Agent", userAgent)

	res, err := client.Do(req)
	if err != nil {
		log.Fatalln(err)
	}
	defer res.Body.Close()
	var index []Index
	resData, err := ioutil.ReadAll(res.Body)
	if err != nil {
		log.Panicln("Couldn't read data from PrivacySpy.")
		log.Panicln(err)
		os.Exit(1)
	}
	err = json.Unmarshal(resData, &index)
	if err != nil {
		log.Panicln("Couldn't parse data from product index.")
		log.Panicln(err)
		os.Exit(1)
	}
	res.Body.Close()

	for _, v := range index {
		slug := v.slug

		// Fetch product data
		productUrl := strings.Join([]string{productUrl,slug,".json"}, "")
		log.Println("Fetching product data: ", productUrl)
		req, err = http.NewRequest("GET", productUrl, nil)
		req.Header.Set("User-Agent", "maatt DOT fr/ps-crawl")
		res, err := client.Do(req)
		if err != nil {
			log.Panicln("Can't access product data.")
			log.Panicln(err)
			os.Exit(1)
		}
		defer res.Body.Close()
		var product Product
		resData, err := ioutil.ReadAll(res.Body)
		if err != nil {
			log.Panicln("Couldn't read data from PrivacySpy.")
			log.Panicln(err)
			os.Exit(1)
		}
		err = json.Unmarshal(resData, &product)
		if err != nil {
			log.Panicln("Couldn't parse data from product data.")
			log.Panicln(err)
			os.Exit(1)
		}
		res.Body.Close()

		// Parse product sources
		policies := product.sources;
		for _, policy := range policies {
			req, err = http.NewRequest("GET", policy, nil)
			req.Header.Set("User-Agent", "maatt DOT fr/ps-crawl")
			res, err := client.Do(req)
			defer res.Body.Close()
			if err != nil {
				log.Panicln("Can't access product website. Skipping...")
				log.Panicln(err)
				res.Body.Close()
			} else {
				body, err := ioutil.ReadAll(res.Body)
				if err != nil {
					log.Panicln("Couldn't read data from PrivacySpy.")
					log.Panicln(err)
					os.Exit(1)
				}
				for _, rubricItem := range product.rubric {
					// Sanitise and check for matches
					for _, citationOrig := range rubricItem.citations {
						re := regexp.MustCompile(`(?:\\n){1,}`)
						var citations []string
						if strings.Contains(citationOrig, "[...]") {
							citations = strings.Split(citationOrig, "[...]")
						} else if re.MatchString(citationOrig) {
							citations = re.Split(citationOrig, -1)
						} else {
							citations = []string{citationOrig}
						}
						for _, citation := range citations {
							citation = strings.ReplaceAll(citationOrig, "[...]", "")
							citation = strings.ReplaceAll(citation, "[â�¦]", "")
							citation = strings.ReplaceAll(citation, "&nbsp;", "")
							re = regexp.MustCompile(`?:\\"`)
							citation = string(re.ReplaceAll([]byte(citation), []byte("")))

							// Check if citation is in source
							if (!strings.Contains(string(body), citation)) {
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
	if runDry { return false }

	// Build GitHub API connection
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: ghToken})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	// Check if issue already exists
	issues, _, err := client.Issues.ListByRepo(ctx, repoOwner, repoName, nil)
	if err != nil {
		log.Panicln("Could not create issue. Halting program to prevent rate-limiting.")
		log.Panicln(err)
		os.Exit(1)
	}
	issueName := strings.Join([]string{"Citation for",product,"not found for",rubricSlug}, " ")
	i := false
	for _, v := range issues {
		if &issueName == v.Title {
			i = true
		}
	}

	// Build issue
	if !i {
		issueMsg := strings.Join([]string{
			"The product, [",
			product,
			"](",
			url,
			", has a missing quote for the rubric item `",
			rubricSlug,
			"`.\n\n```\n",
			citation,
			"\n``` \n---\nI'm just a bot, so I'm not perfect. [Let us know if I've made a mistake.](https://github.com/doamatto/privacyspy-bot/issues) :relaxed:",
		}, "")
		issue, _, err := client.Issues.Create(ctx, repoOwner, repoName, &github.IssueRequest{
			Title: &issueName,
			Body: &issueMsg,
			Labels: &[]string{"product", "help wanted", "problem"},
		})
		if err != nil {
			log.Panicln("Could not create issue. Halting program to prevent rate-limiting.")
			log.Panicln(err)
			os.Exit(1)
		}
		log.Println("Issue created. See %v.", issue.URL)
	} else {
		log.Println("Issue already exists. Skipping creation of issue.")
	}
	return i
}
