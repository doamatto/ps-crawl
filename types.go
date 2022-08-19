package main

type Index struct {
	name string
	hostnames {}string
	slug string
	score int
	icon string
	description string
	lastUpdated string `json:"last_updated"`
}

type Product struct {
	name string
	description string
	hostnames {}string
	sources {}string
	icon string
	slug string
	score int
	parent string
	children any
	rubric []interface{
		question[]interface{
			category string
			slug string
			text string
			notes []interface{}string
			points int
			options []interface{
				id string
				text string
				percent int
			}
		}
		option []interface{
			id string
			text string
			percent int
		}
		notes []interface{}string
		citations []interface{}string
		value string
	}
	updates []interface{}
	lastUpdated string `json:"last_updated`
	contributors []interface{
		slug string
		role string
		name string
		website string
		github string
		email string
	}
}
