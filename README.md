Appstore top apps API
=============================
Fetches top 200 appstore applications by genre and monetization.

* Accessible on https://appstore-apps.herokuapp.com
* To run locally:
  1. run redis: redis-server
  2. run server: rackup
* API:
  1. Top apps list by category and monetization
    https://appstore-apps.herokuapp.com/categories/6008/apps/free
  2. Find app by category, monetization and rank
    https://appstore-apps.herokuapp.com/categories/6008/apps/free/120
  2. Top publishers list by category and monetization
    https://appstore-apps.herokuapp.com/categories/6008/apps/free/publishers