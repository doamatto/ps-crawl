package main

type Index struct {
	name string `json:"name"`
	hostnames []string `json:"hostnames"`
	slug string `json:"slug"`
	score float64 `json:"score"`
	icon string `json:"icon"`
	description string `json:"description"`
	lastUpdated string `json:"lastUpdated"`
}

type Product struct {
	name string `json:"name"`
	description string `json:"description"`
	hostnames []string `json:"hostnames"`
	sources []string `json:"sources"`
	icon string `json:"icon"`
	slug string `json:"slug"`
	score float64 `json:"score"`
	parent string `json:"parent,omitempty"`
	children []interface{} `json:"children,omitempty"`
	rubric []struct{
		question struct{
			category string `json:"category"`
			slug string `json:"slug"`
			text string `json:"text"`
			notes []interface{} `json:"notes"`
			points int `json:"points"`
			options []struct{
				id string `json:"id"`
				text string `json:"text"`
				percent int `json:"percent"`
			}
		}
		option []struct{
			id string `json:"id"`
			text string `json:"text"`
			percent int `json:"percent"`
		}
		notes []struct{} `json:"notes"`
		citations []string `json:"citations"`
		value string `json:"value"`
	} `json:"rubric"`
	updates []struct{} `json:"updates"`
	lastUpdated string `json:"lastUpdated`
	contributors []struct{
		slug string `json:"slug"`
		role string `json:"role"`
		name string `json:"name"`
		website string `json:"website"`
		github string `json:"github"`
		email string `json:"email"`
	} `json:"contributors"`
}
