# README
### Tooling
- Ruby Version is commented out to allow any local ruby to run
- Used SQLite for db to prevent any creds/versioning issues. Recommend PostgreSQL for prod obviously but this should suffice.
- RSPEC for testing with shoulda matchers
- Run `rake db:seed` after migrating your local db

### Features
- Slugification shortens `slugified_slug` value to 30 characters. This can easily be changed via `Slug::MAX_LENGTH`
- `slugified_slug` allow users to submit their own preferred slug to allow stakeholders to maximize SEO, search, and marketing related functions.
  - Slugs will scan for slug collision and automatically append the `slugified_slug` with an increment to ensure slugs remain unique `fathers-day-special`, `fathers-day-special-1`, `fathers-day-special-2`, etc.
  - All user submitted `slugified_slug` values are...
    - stripped of whitespaces removed
    - stripped of special characters  (/, ¶•ªº§ , backticks, apostrophe's, etc )
    - converts `&` to `and`
    - Sanitization will limit to 30 characters (note that collision appends to this making it easy to query for collided slugs `slugified_slug`.length > 30)
  - if users do not enter a preferred `slugified_slug` the same sanitization process will run off the `origin_url`, limiting length. 

### API
- `/localhost:3000/slugs/origin_url`: accepts a `slugified_slug` param over ID and returns the requested slug's `origin_url` for __ACTIVE__ flagged slugs only.  The `slugified_slug` is replaces ID as it is intended to be shared publicly, unique, and indexed, thus removing overhead interfacing with database ID's.

- `http://localhost:3000/slugs/slugify?url=abc`: accepts a `url` param and provides back the user with a recommended slugified value of their provided url. This allows clients/users the option to query and preview what their desired slug will look like.

- `http://localhost:3000/slugs/create`: POST request that only requires a `origin_url` param. If a `slugified_slug` value is provided, it will slugify off that value.

- `http://localhost:3000/slugs/update`: POST request that searches by `slugified_slug` and allows clients to update a slug, this includes deactivating via flipping `active` to `false`. Deactivating a slug is preffered as clients should rarely be able to dictate actual destruction of persisted data in many cases.


### CONSIDERATIONS
Much of this design pattern was carefully constructed off my experience at Cheddar. Though the use cases were different, I think many of the features provided by this dynamic slug model can provide a lot of flexibility with user's demands for being able to curate slugs and receive slug suggestions without necessarily querying endlessly back to the server during instantation, error handling, and other common stop gaps common to request, response cycles off client side forms.


### Cheddar's Problem
Our initial problem set was a bit different, with the need for slugs to be attached to various types of resources. Many slugs, quick feedback on slug preview, editorial freedom to edit slugs prior to publication, retract and edit slugs post publication.


#### 1. MANY THINGS NEEDED SLUGS
This implementation was created with the idea of `products` having `slugs`.

However at Cheddar, many classes required slugable support. 

Our `slugs` table was set to as a polymorphic relationship storing `slugable_id` and `slugable_type` which would be referenced by `Article` or `DraftArticle`, `LegacyArticle`, `Draft`, `Video` classes.

In addition, most the slug's private methods & functionality was actually encapsulated into a `slugable` concern which we used to easily provide slugable support to our desired resource. 

Note that we also allowed the same `slugified_slug` value to exist on different slugable_types! This allowed more stakeholders the flexibility of not having to worry about squatting on topic slug names.


#### 2. CUSTOMIZE SLUGS WITH QUICK FEEDBACK
Editorial and other stakeholders signified the need to be able to customize and preview slugs in real time prior to publishing. 

Some users would leave their clientside CMS form open and return hours later only to learn a different editor had "stolen" their slug. Others were perfectionists and consistently republished content multiple times changing slugs on the fly. Supervising editors were constantly reviewing work and correcting typo's post publication as well. 

He quickly learned that the slugification process had to be idempotent and had to really encapsulated all the logic to allow clients to be as abstract and clueless about this process as possible.

The preview feedback of a slugified slug allowed users to know what the recommended slug would be, an endpoint to query and preview their desired slug, as well as ensure a rules engine to prevent slugs from colliding. This sort functionality played particularly well in Graphql as you could create a query with interfaces to tack on additional fields, or utilize the relay api to allow refetch containers, alleviating the need to make redundant separate queries from the client side (forms did not have to care about this state at all).

## 3. SLUG TREE
This was by the far the biggest slug requirement we dealt with at Cheddar. Although this current implemenetation does not include it, the slug mechanisms provided here were some of the most difficult challenges to overcome for our most daunting feature request.

Editors wanted a slug on an article and a video. 

`article.slug = "garbage_smells"`
`video.slug = "garbage_smells"`

What if a video was attached/detached to a video? How could we re-assign all the video slugs over while preserving the ability to also detach that relationship.

All video slugs pointing to the `garbage_smells` video (`garbage_smells-1`, `garbage_smells-6`, `stinky_garbage`) must continue to point to that video. 

All article slugs pointing to the `garbage_smells` article (`garbage_smells-1`, `garbage_smells-2`, `stinky_garbage`, `stinky_garbage-1`) must continue to point to that article.

However, all those videos slugs must be able to point to the article's parent slug if we attach that video to the article. 

We also need to retain each resources' previous slug lineage should we detach a video from an article. 

We accomplished this by also adding a self_referencing indexed column to `slugs` via `parent_slug_id`.

We then included additional slug support to recursively traverse each slug and it's parent slug until none were found. At this parent node, we could easily reassign that parent slug to a different slugs's polymorphic id. This allowed us to easily point an entire slugs tree to a different tree's resources (all slugs pointing to the same origin regardless of type's, republications, etc) now all pointing to route users to a different resource.

### KNOWN BUGS
- Slug collision does have limitations. Most noteworthy was when editorial published a title ending in `-integer`. Our slugification process occurred off `title` instead of `origin_url` so naturally we once published a slug ending with infamous rapper `tekashi-70` as it was auto-incremented. 
  - We created a bug ticket for that but it was such an rare edgecase that product placed it under severely low priority and into the ice box.
- SQLite does not allow case insensitive searches via `ILIKE`. I was not aware of that till this exercise.


### FINAL THOUGHTS
If I had more time, I wanted to decouple the idea of activating / deactivating a slug into a separate endpoint. 

I honestly was not thrilled with the routing in general. Once you really escape basic CRUD and embrace GRAPHQL, the notion of REST API's seem so limited.

I instinctively want to create abstract, dynamic endpoints but without the type safety, I found myself spending a lot of time and effort hand crafting error handling, consistent status response output, type safety of params, etc.

After mutation I found myself instinctively wanting to return back the resource as a whole (since a user might want to view the data in a refreshed form of sort).

However with basic get queries I wanted to limit the hefty baggage of REST and only serve what was asked. I tried to provide some uniform pattern of expectation for response shapes depending on if you made a customized get request or post request to mutate data. It stills a bit off for me. Not the worst but a bit conventionless. 
