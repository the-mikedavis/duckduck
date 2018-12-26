defmodule DuckDuck.TestData do
  def token_http_response do
    {:ok,
     %HTTPoison.Response{
       body:
         "{\"id\":148537170,\"node_id\":\"MDEwOlJlcG9zaXRvcnkxNDg1MzcxNzA=\",\"name\":\"doc_gen\",\"full_name\":\"the-mikedavis/doc_gen\",\"private\":false,\"owner\":{\"login\":\"the-mikedavis\",\"id\":21230295,\"node_id\":\"MDQ6VXNlcjIxMjMwMjk1\",\"avatar_url\":\"https://avatars2.githubusercontent.com/u/21230295?v=4\",\"gravatar_id\":\"\",\"url\":\"https://api.github.com/users/the-mikedavis\",\"html_url\":\"https://github.com/the-mikedavis\",\"followers_url\":\"https://api.github.com/users/the-mikedavis/followers\",\"following_url\":\"https://api.github.com/users/the-mikedavis/following{/other_user}\",\"gists_url\":\"https://api.github.com/users/the-mikedavis/gists{/gist_id}\",\"starred_url\":\"https://api.github.com/users/the-mikedavis/starred{/owner}{/repo}\",\"subscriptions_url\":\"https://api.github.com/users/the-mikedavis/subscriptions\",\"organizations_url\":\"https://api.github.com/users/the-mikedavis/orgs\",\"repos_url\":\"https://api.github.com/users/the-mikedavis/repos\",\"events_url\":\"https://api.github.com/users/the-mikedavis/events{/privacy}\",\"received_events_url\":\"https://api.github.com/users/the-mikedavis/received_events\",\"type\":\"User\",\"site_admin\":false},\"html_url\":\"https://github.com/the-mikedavis/doc_gen\",\"description\":\"A reduced-bias way to create documentaries\",\"fork\":false,\"url\":\"https://api.github.com/repos/the-mikedavis/doc_gen\",\"forks_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/forks\",\"keys_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/keys{/key_id}\",\"collaborators_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/collaborators{/collaborator}\",\"teams_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/teams\",\"hooks_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/hooks\",\"issue_events_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/issues/events{/number}\",\"events_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/events\",\"assignees_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/assignees{/user}\",\"branches_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/branches{/branch}\",\"tags_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/tags\",\"blobs_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/git/blobs{/sha}\",\"git_tags_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/git/tags{/sha}\",\"git_refs_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/git/refs{/sha}\",\"trees_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/git/trees{/sha}\",\"statuses_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/statuses/{sha}\",\"languages_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/languages\",\"stargazers_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/stargazers\",\"contributors_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/contributors\",\"subscribers_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/subscribers\",\"subscription_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/subscription\",\"commits_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/commits{/sha}\",\"git_commits_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/git/commits{/sha}\",\"comments_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/comments{/number}\",\"issue_comment_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/issues/comments{/number}\",\"contents_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/contents/{+path}\",\"compare_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/compare/{base}...{head}\",\"merges_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/merges\",\"archive_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/{archive_format}{/ref}\",\"downloads_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/downloads\",\"issues_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/issues{/number}\",\"pulls_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/pulls{/number}\",\"milestones_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/milestones{/number}\",\"notifications_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/notifications{?since,all,participating}\",\"labels_url\":\"https://api.github.com/repo",
       headers: [
         {"Server", "GitHub.com"},
         {"Date", "Wed, 26 Dec 2018 01:29:00 GMT"},
         {"Content-Type", "application/json; charset=utf-8"},
         {"Content-Length", "5263"},
         {"Status", "200 OK"},
         {"X-RateLimit-Limit", "5000"},
         {"X-RateLimit-Remaining", "4999"},
         {"X-RateLimit-Reset", "1545791340"},
         {"Cache-Control", "private, max-age=60, s-maxage=60"},
         {"Vary", "Accept, Authorization, Cookie, X-GitHub-OTP"},
         {"ETag", "\"f137c87c6f1300115c008056e588df28\""},
         {"Last-Modified", "Wed, 12 Dec 2018 23:24:33 GMT"},
         {"X-OAuth-Scopes", "repo"},
         {"X-Accepted-OAuth-Scopes", "repo"},
         {"X-GitHub-Media-Type", "github.v3; format=json"},
         {"Access-Control-Expose-Headers",
          "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type"},
         {"Access-Control-Allow-Origin", "*"},
         {"Strict-Transport-Security",
          "max-age=31536000; includeSubdomains; preload"},
         {"X-Frame-Options", "deny"},
         {"X-Content-Type-Options", "nosniff"},
         {"X-XSS-Protection", "1; mode=block"},
         {"Referrer-Policy",
          "origin-when-cross-origin, strict-origin-when-cross-origin"},
         {"Content-Security-Policy", "default-src 'none'"},
         {"X-GitHub-Request-Id", "BC5A:1B6E:2751592:64FA15B:5C22D95C"}
       ],
       request: %HTTPoison.Request{
         body: "",
         headers: [
           {"Authorization", "token TOKEN"}
         ],
         method: :get,
         options: [],
         params: %{},
         url: "https://api.github.com/repos/the-mikedavis/doc_gen"
       },
       request_url: "https://api.github.com/repos/the-mikedavis/doc_gen",
       status_code: 200
     }}
  end

  def http_upload_url_response do
    %HTTPoison.Response{
      body:
        "{\"url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/releases/14504222\",\"assets_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/releases/14504222/assets\",\"upload_url\":\"https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14504222/assets{?name,label}\",\"html_url\":\"https://github.com/the-mikedavis/doc_gen/releases/tag/v27\",\"id\":14504222,\"node_id\":\"MDc6UmVsZWFzZTE0NTA0MjIy\",\"tag_name\":\"v27\",\"target_commitish\":\"master\",\"name\":null,\"draft\":false,\"author\":{\"login\":\"the-mikedavis\",\"id\":21230295,\"node_id\":\"MDQ6VXNlcjIxMjMwMjk1\",\"avatar_url\":\"https://avatars2.githubusercontent.com/u/21230295?v=4\",\"gravatar_id\":\"\",\"url\":\"https://api.github.com/users/the-mikedavis\",\"html_url\":\"https://github.com/the-mikedavis\",\"followers_url\":\"https://api.github.com/users/the-mikedavis/followers\",\"following_url\":\"https://api.github.com/users/the-mikedavis/following{/other_user}\",\"gists_url\":\"https://api.github.com/users/the-mikedavis/gists{/gist_id}\",\"starred_url\":\"https://api.github.com/users/the-mikedavis/starred{/owner}{/repo}\",\"subscriptions_url\":\"https://api.github.com/users/the-mikedavis/subscriptions\",\"organizations_url\":\"https://api.github.com/users/the-mikedavis/orgs\",\"repos_url\":\"https://api.github.com/users/the-mikedavis/repos\",\"events_url\":\"https://api.github.com/users/the-mikedavis/events{/privacy}\",\"received_events_url\":\"https://api.github.com/users/the-mikedavis/received_events\",\"type\":\"User\",\"site_admin\":false},\"prerelease\":false,\"created_at\":\"2018-12-12T23:25:10Z\",\"published_at\":\"2018-12-12T23:30:21Z\",\"assets\":[{\"url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/releases/assets/10124137\",\"id\":10124137,\"node_id\":\"MDEyOlJlbGVhc2VBc3NldDEwMTI0MTM3\",\"name\":\"doc_gen.tar.gz\",\"label\":\"\",\"uploader\":{\"login\":\"the-mikedavis\",\"id\":21230295,\"node_id\":\"MDQ6VXNlcjIxMjMwMjk1\",\"avatar_url\":\"https://avatars2.githubusercontent.com/u/21230295?v=4\",\"gravatar_id\":\"\",\"url\":\"https://api.github.com/users/the-mikedavis\",\"html_url\":\"https://github.com/the-mikedavis\",\"followers_url\":\"https://api.github.com/users/the-mikedavis/followers\",\"following_url\":\"https://api.github.com/users/the-mikedavis/following{/other_user}\",\"gists_url\":\"https://api.github.com/users/the-mikedavis/gists{/gist_id}\",\"starred_url\":\"https://api.github.com/users/the-mikedavis/starred{/owner}{/repo}\",\"subscriptions_url\":\"https://api.github.com/users/the-mikedavis/subscriptions\",\"organizations_url\":\"https://api.github.com/users/the-mikedavis/orgs\",\"repos_url\":\"https://api.github.com/users/the-mikedavis/repos\",\"events_url\":\"https://api.github.com/users/the-mikedavis/events{/privacy}\",\"received_events_url\":\"https://api.github.com/users/the-mikedavis/received_events\",\"type\":\"User\",\"site_admin\":false},\"content_type\":\"application/octet-stream\",\"state\":\"uploaded\",\"size\":63448393,\"download_count\":1,\"created_at\":\"2018-12-12T23:30:21Z\",\"updated_at\":\"2018-12-12T23:30:26Z\",\"browser_download_url\":\"https://github.com/the-mikedavis/doc_gen/releases/download/v27/doc_gen.tar.gz\"}],\"tarball_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/tarball/v27\",\"zipball_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/zipball/v27\",\"body\":null}",
      headers: [
        {"Server", "GitHub.com"},
        {"Date", "Wed, 26 Dec 2018 01:29:00 GMT"},
        {"Content-Type", "application/json; charset=utf-8"},
        {"Content-Length", "3153"},
        {"Status", "200 OK"},
        {"X-RateLimit-Limit", "5000"},
        {"X-RateLimit-Remaining", "4998"},
        {"X-RateLimit-Reset", "1545791340"},
        {"Cache-Control", "private, max-age=60, s-maxage=60"},
        {"Vary", "Accept, Authorization, Cookie, X-GitHub-OTP"},
        {"ETag", "\"08f2674cd27f9794352b886bc541754e\""},
        {"Last-Modified", "Wed, 12 Dec 2018 23:30:21 GMT"},
        {"X-OAuth-Scopes", "repo"},
        {"X-Accepted-OAuth-Scopes", "repo"},
        {"X-GitHub-Media-Type", "github.v3; format=json"},
        {"Access-Control-Expose-Headers",
         "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type"},
        {"Access-Control-Allow-Origin", "*"},
        {"Strict-Transport-Security",
         "max-age=31536000; includeSubdomains; preload"},
        {"X-Frame-Options", "deny"},
        {"X-Content-Type-Options", "nosniff"},
        {"X-XSS-Protection", "1; mode=block"},
        {"Referrer-Policy",
         "origin-when-cross-origin, strict-origin-when-cross-origin"},
        {"Content-Security-Policy", "default-src 'none'"},
        {"X-GitHub-Request-Id", "BC5A:1B6E:2751593:64FA15D:5C22D95C"}
      ],
      request: %HTTPoison.Request{
        body: "",
        headers: [
          {"Authorization", "token TOKEN"}
        ],
        method: :get,
        options: [],
        params: %{},
        url:
          "https://api.github.com/repos/the-mikedavis/doc_gen/releases/tags/v27"
      },
      request_url:
        "https://api.github.com/repos/the-mikedavis/doc_gen/releases/tags/v27",
      status_code: 200
    }
  end

  def tag_not_release_response do
    %HTTPoison.Response{
      body:
        "{\"message\":\"Not Found\",\"documentation_url\":\"https://developer.github.com/v3/repos/releases/#get-a-release-by-tag-name\"}",
      headers: [
        {"Server", "GitHub.com"},
        {"Date", "Wed, 26 Dec 2018 14:23:52 GMT"},
        {"Content-Type", "application/json; charset=utf-8"},
        {"Content-Length", "119"},
        {"Status", "404 Not Found"},
        {"X-RateLimit-Limit", "5000"},
        {"X-RateLimit-Remaining", "4943"},
        {"X-RateLimit-Reset", "1545837134"},
        {"X-OAuth-Scopes", "repo"},
        {"X-Accepted-OAuth-Scopes", "repo"},
        {"X-GitHub-Media-Type", "github.v3; format=json"},
        {"Access-Control-Expose-Headers",
         "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type"},
        {"Access-Control-Allow-Origin", "*"},
        {"Strict-Transport-Security",
         "max-age=31536000; includeSubdomains; preload"},
        {"X-Frame-Options", "deny"},
        {"X-Content-Type-Options", "nosniff"},
        {"X-XSS-Protection", "1; mode=block"},
        {"Referrer-Policy",
         "origin-when-cross-origin, strict-origin-when-cross-origin"},
        {"Content-Security-Policy", "default-src 'none'"},
        {"X-GitHub-Request-Id", "BC6F:1B71:601F9DF:C4C8B5D:5C238EF8"}
      ],
      request: %HTTPoison.Request{
        body: "",
        headers: [
          {"Authorization", "token TOKEN"}
        ],
        method: :get,
        options: [],
        params: %{},
        url:
          "https://api.github.com/repos/the-mikedavis/doc_gen/releases/tags/v28"
      },
      request_url:
        "https://api.github.com/repos/the-mikedavis/doc_gen/releases/tags/v28",
      status_code: 404
    }
  end

  def create_release_from_tag_response do
    %HTTPoison.Response{
      body:
        "{\"url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/releases/14702417\",\"assets_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/releases/14702417/assets\",\"upload_url\":\"https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14702417/assets{?name,label}\",\"html_url\":\"https://github.com/the-mikedavis/doc_gen/releases/tag/v28\",\"id\":14702417,\"node_id\":\"MDc6UmVsZWFzZTE0NzAyNDE3\",\"tag_name\":\"v28\",\"target_commitish\":\"master\",\"name\":null,\"draft\":false,\"author\":{\"login\":\"the-mikedavis\",\"id\":21230295,\"node_id\":\"MDQ6VXNlcjIxMjMwMjk1\",\"avatar_url\":\"https://avatars2.githubusercontent.com/u/21230295?v=4\",\"gravatar_id\":\"\",\"url\":\"https://api.github.com/users/the-mikedavis\",\"html_url\":\"https://github.com/the-mikedavis\",\"followers_url\":\"https://api.github.com/users/the-mikedavis/followers\",\"following_url\":\"https://api.github.com/users/the-mikedavis/following{/other_user}\",\"gists_url\":\"https://api.github.com/users/the-mikedavis/gists{/gist_id}\",\"starred_url\":\"https://api.github.com/users/the-mikedavis/starred{/owner}{/repo}\",\"subscriptions_url\":\"https://api.github.com/users/the-mikedavis/subscriptions\",\"organizations_url\":\"https://api.github.com/users/the-mikedavis/orgs\",\"repos_url\":\"https://api.github.com/users/the-mikedavis/repos\",\"events_url\":\"https://api.github.com/users/the-mikedavis/events{/privacy}\",\"received_events_url\":\"https://api.github.com/users/the-mikedavis/received_events\",\"type\":\"User\",\"site_admin\":false},\"prerelease\":false,\"created_at\":\"2018-12-26T14:17:39Z\",\"published_at\":\"2018-12-26T14:23:52Z\",\"assets\":[],\"tarball_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/tarball/v28\",\"zipball_url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/zipball/v28\",\"body\":null}",
      headers: [
        {"Server", "GitHub.com"},
        {"Date", "Wed, 26 Dec 2018 14:23:52 GMT"},
        {"Content-Type", "application/json; charset=utf-8"},
        {"Content-Length", "1723"},
        {"Status", "201 Created"},
        {"X-RateLimit-Limit", "5000"},
        {"X-RateLimit-Remaining", "4942"},
        {"X-RateLimit-Reset", "1545837134"},
        {"Cache-Control", "private, max-age=60, s-maxage=60"},
        {"Vary", "Accept, Authorization, Cookie, X-GitHub-OTP"},
        {"ETag", "\"75fd930455fa979fe1dc6d105a980b36\""},
        {"X-OAuth-Scopes", "repo"},
        {"X-Accepted-OAuth-Scopes", "repo"},
        {"Location",
         "https://api.github.com/repos/the-mikedavis/doc_gen/releases/14702417"},
        {"X-GitHub-Media-Type", "github.v3; format=json"},
        {"Access-Control-Expose-Headers",
         "ETag, Link, Location, Retry-After, X-GitHub-OTP, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval, X-GitHub-Media-Type"},
        {"Access-Control-Allow-Origin", "*"},
        {"Strict-Transport-Security",
         "max-age=31536000; includeSubdomains; preload"},
        {"X-Frame-Options", "deny"},
        {"X-Content-Type-Options", "nosniff"},
        {"X-XSS-Protection", "1; mode=block"},
        {"Referrer-Policy",
         "origin-when-cross-origin, strict-origin-when-cross-origin"},
        {"Content-Security-Policy", "default-src 'none'"},
        {"X-GitHub-Request-Id", "BC6F:1B71:601F9E6:C4C8B64:5C238EF8"}
      ],
      request: %HTTPoison.Request{
        body: "{\"tag_name\":\"v28\"}",
        headers: [
          {"Authorization", "token TOKEN"}
        ],
        method: :post,
        options: [],
        params: %{},
        url: "https://api.github.com/repos/the-mikedavis/doc_gen/releases"
      },
      request_url:
        "https://api.github.com/repos/the-mikedavis/doc_gen/releases",
      status_code: 201
    }
  end

  def post_file_already_exists_response do
    %HTTPoison.Response{
      body:
        "{\"message\":\"Validation Failed\",\"request_id\":\"924C:48FF:303E11:393425:5C23F20A\",\"documentation_url\":\"https://developer.github.com/v3\",\"errors\":[{\"resource\":\"ReleaseAsset\",\"code\":\"already_exists\",\"field\":\"name\"}]}",
      headers: [
        {"Cache-Control", "no-cache"},
        {"Content-Length", "211"},
        {"Content-Security-Policy", "default-src 'none'"},
        {"Content-Type", "application/json; charset=utf-8"},
        {"Strict-Transport-Security", "max-age=31557600"},
        {"X-Accepted-Oauth-Scopes", "repo"},
        {"X-Content-Type-Options", "nosniff"},
        {"X-Frame-Options", "deny"},
        {"X-Github-Media-Type", "github.v3; format=json"},
        {"X-Oauth-Scopes", "repo"},
        {"X-Xss-Protection", "1; mode=block"},
        {"Date", "Wed, 26 Dec 2018 21:26:34 GMT"},
        {"X-GitHub-Request-Id", "924C:48FF:303E11:393425:5C23F20A"}
      ],
      request: %HTTPoison.Request{
        body:
          {:file,
           "/vagrant/code/doc_gen/_build/prod/rel/doc_gen/releases/v28-0-gb290881/doc_gen.tar.gz"},
        headers: [
          {"Authorization", "token TOKEN"}
        ],
        method: :post,
        options: [timeout: 50000, recv_timeout: 50000],
        params: %{},
        url:
          "https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14702417/assets?name=doc_gen.tar.gz"
      },
      request_url:
        "https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14702417/assets?name=doc_gen.tar.gz",
      status_code: 422
    }
  end

  def post_file_bad_token do
    %HTTPoison.Response{
      body:
        "{\"message\":\"Not Found\",\"request_id\":\"99B7:48FD:E4206:11593E:5C23F263\",\"documentation_url\":\"https://developer.github.com/v3\"}",
      headers: [
        {"Cache-Control", "no-cache"},
        {"Content-Length", "124"},
        {"Content-Security-Policy", "default-src 'none'"},
        {"Content-Type", "application/json; charset=utf-8"},
        {"Strict-Transport-Security", "max-age=31557600"},
        {"X-Accepted-Oauth-Scopes", "repo"},
        {"X-Content-Type-Options", "nosniff"},
        {"X-Frame-Options", "deny"},
        {"X-Github-Media-Type", "github.v3; format=json"},
        {"X-Oauth-Scopes", "repo"},
        {"X-Xss-Protection", "1; mode=block"},
        {"Date", "Wed, 26 Dec 2018 21:28:03 GMT"},
        {"X-GitHub-Request-Id", "99B7:48FD:E4206:11593E:5C23F263"}
      ],
      request: %HTTPoison.Request{
        body:
          {:file,
           "/vagrant/code/doc_gen/_build/prod/rel/doc_gen/releases/v28-0-gb290881/doc_gen.tar.gz"},
        headers: [
          {"Authorization", "token TOKEN"}
        ],
        method: :post,
        options: [timeout: 50000, recv_timeout: 50000],
        params: %{},
        url:
          "https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14702417/assets?name=doc_gen.tar.gz"
      },
      request_url:
        "https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14702417/assets?name=doc_gen.tar.gz",
      status_code: 404
    }
  end

  def post_file_success do
    %HTTPoison.Response{
      body:
        "{\"url\":\"https://api.github.com/repos/the-mikedavis/doc_gen/releases/assets/10315091\",\"id\":10315091,\"node_id\":\"MDEyOlJlbGVhc2VBc3NldDEwMzE1MDkx\",\"name\":\"doc_gen.tar.gz\",\"label\":\"\",\"uploader\":{\"login\":\"the-mikedavis\",\"id\":21230295,\"node_id\":\"MDQ6VXNlcjIxMjMwMjk1\",\"avatar_url\":\"https://avatars2.githubusercontent.com/u/21230295?v=4\",\"gravatar_id\":\"\",\"url\":\"https://api.github.com/users/the-mikedavis\",\"html_url\":\"https://github.com/the-mikedavis\",\"followers_url\":\"https://api.github.com/users/the-mikedavis/followers\",\"following_url\":\"https://api.github.com/users/the-mikedavis/following{/other_user}\",\"gists_url\":\"https://api.github.com/users/the-mikedavis/gists{/gist_id}\",\"starred_url\":\"https://api.github.com/users/the-mikedavis/starred{/owner}{/repo}\",\"subscriptions_url\":\"https://api.github.com/users/the-mikedavis/subscriptions\",\"organizations_url\":\"https://api.github.com/users/the-mikedavis/orgs\",\"repos_url\":\"https://api.github.com/users/the-mikedavis/repos\",\"events_url\":\"https://api.github.com/users/the-mikedavis/events{/privacy}\",\"received_events_url\":\"https://api.github.com/users/the-mikedavis/received_events\",\"type\":\"User\",\"site_admin\":false},\"content_type\":\"application/octet-stream\",\"state\":\"uploaded\",\"size\":63463499,\"download_count\":0,\"created_at\":\"2018-12-26T21:39:39Z\",\"updated_at\":\"2018-12-26T21:40:48Z\",\"browser_download_url\":\"https://github.com/the-mikedavis/doc_gen/releases/download/v30/doc_gen.tar.gz\"}",
      headers: [
        {"Cache-Control", "no-cache"},
        {"Content-Security-Policy", "default-src 'none'"},
        {"Content-Type", "application/json; charset=utf-8"},
        {"Etag", "W/\"0c93e1ececeaf133f9569e62af6dead9\""},
        {"Last-Modified", "Wed, 26 Dec 2018 21:40:48 GMT"},
        {"Strict-Transport-Security", "max-age=31557600"},
        {"Vary", "Accept, Authorization, Cookie, X-GitHub-OTP"},
        {"X-Accepted-Oauth-Scopes", "repo"},
        {"X-Content-Type-Options", "nosniff"},
        {"X-Frame-Options", "deny"},
        {"X-Github-Media-Type", "github.v3; format=json"},
        {"X-Oauth-Scopes", "repo"},
        {"X-Xss-Protection", "1; mode=block"},
        {"Date", "Wed, 26 Dec 2018 21:40:48 GMT"},
        {"Transfer-Encoding", "chunked"},
        {"X-GitHub-Request-Id", "9E16:48FF:30703A:396D35:5C23F51B"}
      ],
      request: %HTTPoison.Request{
        body:
          {:file,
           "/vagrant/code/doc_gen/_build/prod/rel/doc_gen/releases/v30-0-gb290881/doc_gen.tar.gz"},
        headers: [
          {"Authorization", "token TOKEN"}
        ],
        method: :post,
        options: [timeout: :infinity, recv_timeout: :infinity],
        params: %{},
        url:
          "https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14707086/assets?name=doc_gen.tar.gz"
      },
      request_url:
        "https://uploads.github.com/repos/the-mikedavis/doc_gen/releases/14707086/assets?name=doc_gen.tar.gz",
      status_code: 201
    }
  end
end
