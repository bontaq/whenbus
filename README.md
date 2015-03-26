A faster way to lookup bus times for Pittsburgh, PA.

After installing Elixir and postgres (I used brew for both), you're just a few steps away.

1. Install dependencies with ```mix deps.get```
2. Create whenbus with ```createdb whenbus```
3. Create testing databse with ```createdb whenbustest```

In the postgres shell, for both test & main database, run
```
CREATE EXTENSION cube;
CREATE EXTENSION earthdistance;
```

4. ```mix whenbus.loadTrips```
5. ```mix whenbus.loadStops```
6. ```mix whenbus.loadTimes```
7. ```mix ecto.migrate```
8. ```MIX_ENV=test mix ecto.migrate```
9. ```mix phoenix.server```

Also to note, styling is done with compass.  Install it how you like and ```compass compile``` or ```compass watch```

Hopefully whenbus is now running locally, let me know if you have any issues :)
