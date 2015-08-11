Appstore top apps API
=============================
Fetches top 200 appstore applications by genre and monetization.

* Accessible on http://appstore-apps.herokuapp.com
* To run locally:
  - run redis: redis-server
  - run server: rackup
* API:
  - Top apps list by category and monetization
    http://appstore-apps.herokuapp.com/categories/6008/apps/free
  - Find app by category, monetization and rank
    http://appstore-apps.herokuapp.com/categories/6008/apps/free/120
  - Top publishers list by category and monetization
    http://appstore-apps.herokuapp.com/categories/6008/apps/free/publishers