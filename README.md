TitanicDMC-R2-Movies
====================

## Background

Welcome!

This is my GitHub project for the second round of the ANZ "Titanic" Data Mining Competition.

The aims of the competition are to increase our modelling skill and learn new tools and techniques for data
mining by attempting a series of practice challenges.

This particular problem involved predicting how users would rate specific films.  Data was sourced from [MovieLens](http://www.movielens.org)

## The Problem
We were given 60k ratings - records containing a user, film and rating.  Our tasks was to predict the rating for ~10k unknown ratings - records containing a user and film but no rating.

We also had information on the names, release dates and genres of all films, and the age and occupation of all users.

Scoring was based on total absolute error.

## My Approach

My aim was to develop a process for working on this problem that would facilitate switching easily between home and work.
I also wanted to be able to share my work easily with colleagues and potential future employers.
I also wanted it to be fun!

### Tools and Techniques

I decided to use GitHub to manage all my code, and run a PostgreSQL server on an AWS instance.
I thought the common PostgreSQL server would help keep my environment consistent between home and work.
I wasn't sure whether PostgreSQL would be up to the task in terms of using the latest data mining techniques,
but I wanted to see what I could come up with anyway given its limitations.  In the first round a simple model had won
so I thought I might at least be able to get somewhere by using clever averages.

Unfortunately I realised down the track that a Micro AWS instance was a bit slow for handling some of the stuff
I through at it, so I ended up using separate servers on my home and work laptop - with some duplication of effort
in loading the same tables to both etc.

### Submission 1 - Rounded Averages

Some early analytic work showed that all the films and users in the test set that we would need to score
had some ratings already.  I tried a few different approaches - film average, user average and overall average
before settling on a combination of the three.  I initially submitted the scores un-rounded, but later realised
that rounding would usually do more help than harm and made another submission with rounded scores.

### Submission 2 - Similarity Scores

I had the idea of calculating the 'distance' between any two users by looking at how similar their scores were across
all films that they had both rated.  Then I would give each film a score based on how the most similar user who had
also rated that film scored it.
My initial attempts went horribly wrong and took forever to run, but I thought
of several ways to improve across the course of the project:
* I used bitmasks to concisely express which films a user had rated, and how well they rated them (4 or 5 stars was
a 1, anything else was a 0).
* I realised that the most prolific raters would account for a higher proportion of all ratings.  I also supposed that
if there were any patterns in the way people rated films I should be able do discover them in a sample of the top 100
or so raters.
* I supposed that only sometimes would the score of the most similar user be an improvement on my averages method (i.e. when similarity was
high!) so made sure that I would only use the similar users score when similarity was above a threshold.
* I found that a similar user's score was less likely to be helpful if it was in the extreme range (e.g. 1, 2, 5).  When
I tested on the training set, it was more helpful to use he similar user's score as a guide for rounding (use floor
rounding when the score was low, ceil rounding when it was high).

## Results

My Rounded Averages model had the lowest error of all models submitted to the competition with an error of 7,140.
This surprised me a little as the Similarity Scores model performed much better on the training set.  There were quite
a few parameters to tweak, so I suppose I'm guilty of overfitting.  To fix this, next time I'll be sure to carve away
a portion of my training set as my own test set to help choose optimal parameters for my models.  I would probably
also try moving away from bitmasks as a summary of how users rated each film and use a string with their actual scores
instead.

## How to Use

I'm not really expecting anyone to try this at home - the code is mainly here so that people can take a look at what
I did.  I've tried to remove everything unnecessary to get to the core ideas.

Both submissions depend on some common code "load_data.sql" kept in the "Data Prep" directory along with the raw CSV files we were
given as inputs.  The paths in that code are hard-coded and will need to be changed to suit your deployment.

The averages submission is pretty simple - use the one file contained in its directory.  For the similarity scores model
the code has been split into 5 files, each of which create some temporary tables and need to be run in order.
