# MovieDict. What do they call it?

## International movie title database for iPhone

![Screenshot](https://moviedict.info/iphone.png)

An app for travelers, language learners and bilingual couples who like to talk about their favourite films.
[Check out the homepage](https://moviedict.info) for a little blurb about the project.

## How does it work?

The most reliable way to look up a movie’s title in a different languages is to find it on Wikipedia, then follow the links to translations of the article.
This is a frustrating workflow on a smartphone, though, especially when the signal is weak.
This (multi-)weekend project transforms a Wikipedia dump into a tiny SQLite file, and the MovieDict app for iOS then searches the database using Unicode-enabled full-text search.

## Why not use IMDb?

IMDb does not support Chinese or Japanese characters (among others), and is not available offline (when traveling).

## Building the database

* Download and extract enwiki, zhwiki, enwiki langlinks to a folder that has roughly 100 GB of free space.
* Import the langlinks table into MySQL: `mysqladmin -uroot -p create wikidumps && mysql -Dwikidumps -uroot -p < .../enwiki-20141106-langlinks.sql` (should take about an hour).
* Then take a look at the `Rakefile`. There is a task that will run the full process, but manually running things step-by-step while reading the Ruby scripts is the recommended workflow.

## License

This is a free app with no business model, and the source code is available under the MIT license. [See the LICENSE file for details.](LICENSE)
