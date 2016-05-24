# Pokestat 2

A web app which displays visualizations of the usage statistics churned out by the Pokemon simulator [Pokemon Showdown](http://pokemonshowdown.com/), and hosted on [smogon](http://www.smogon.com/stats/). The site itself is hosted at [pokestat.org.uk](http://pokestat.org.uk). A very simple rails app which caches the usage stats in a SQL backend, serves them over a HTTP API to the front end which renders using ChartJS.

I'd like to thank Antar of the Smogon Forums for collating the stats, and the Pokemon Showdown team for provding a simulator that drives the community to this day.

This is a revamp of the [original Pokestat project](https://github.com/ishakir/PokeStat), which was originally too limited in it's scope and eventually died due to over-ambition, and lack of experience on my part. Over the original, Pokestat 2 offers:

- A deeper history
- Automated upload of new data
- A larger selection of generations and tiers