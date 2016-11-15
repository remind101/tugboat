##### GitHub OAuth HTTP handler

See <https://godoc.org/github.com/kr/githubauth> for documentation.

###### Example

```go
h := &githubauth.Handler{
	RequireOrg:   "mycorp",
	Keys:         keys(),
	ClientID:     os.Getenv("OAUTH_CLIENT_ID"),
	ClientSecret: os.Getenv("OAUTH_CLIENT_SECRET"),
}
http.ListenAndServe(":8080", h)
```
