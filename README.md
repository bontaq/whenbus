A faster way to lookup bus times for Pittsburgh, PA.

After installing Elixir and postgres (I used brew for both), you're just a few steps away.

1. Install dependencies with `mix deps.get`
2. Start Phoenix endpoint with `mix phoenix.server`

In the postgres shell, for both test & main database, run
CREATE EXTENSION cube;
CREATE EXTENSION earthdistance;
