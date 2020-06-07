# README

### NOTES
- Rspec for testing
- SQLite for ease of portability (prefer PG on prod but having recently worked on a code challenge where I was specifically told to use SQLite, I forget how seamless it worked on anyone's local regardless of versioning and is perfect for these sort of challenges).
- Slug tree..
  - Slugs point to parent_slug id
    - If no slug, that is the latest_node on tree
- Ruby 2.7 


### Functionality
- Slugify slugs
  - check for collision
  - slugify
    - downcase
    - sanitize
    - shorten

# Slug Table / Model
- origin_url, string
- slugified_slug. string
- is_active: boolean
- parent_slug_id :default null, index
- users should be able to hit the slugified ex:
  'https://reqres.in/api/users?page=2'


Tasks
- Slug table
- Slug model

- create custom slug
  - slug should be slugified
- separate route to slugify
- update a slug
- delete a slug
- open url and get directed


Bonus:
- slug tree
- polymoprhic table
- move to slugable concern and include in other polymorphic models
- auto complete slugs for search
- sanitization / normalization for protocol logic... http / https

-----

##### SPECS
URL Shortener: Back End

Your task is to build the back end of a web service for shortening URLs. This will be an API service that a client would communicate with. The deliverable is the source code, written in Ruby, using whichever libraries, tools, database(s), and development methodologies you choose.

The requirements intentionally leave out many details. This is an opportunity for you to make decisions about the design of the service. What you leave out is just as important as what you include!

Product Requirements:

- Clients should be able to create a shortened URL from a longer URL.
- Clients should be able to specify a custom slug.
- Clients should be able to expire / delete previous URLs.
- Users should be able to open the URL and get redirected.

Project Requirements:

- The project should include an automated test suite.
- The project should include a README file with instructions for running the web service and its tests. You should also use the README to provide context on choices made during development.
- The project should be packaged as a zip file or submitted via a hosted git platform (Github, Gitlab, etc).
