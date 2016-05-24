Ok, so for now we'll go with two tables, simply:

SOURCE_ID,YEAR,MONTH,GENERATION,TIER,MIN_RANK,FILENAME (implicit created_at and updated_at)

POKEMON,USAGE,SOURCE_ID

Will write a simple loader (as a rails adhoc script) that just dumps the contents of the usage.txt files on the smogon server into this table, and then can copy the front end code from the old PokeStat to render the graphs. Need a simple ruby backend to serve the data no problem. Bing Bang Boom. Should have over one years worth of data for people to dig into.

Will buy back the domain name tonight, and then we're definitely laughing in a couple days time. Would be nice to get the whole thing running locally tonight.