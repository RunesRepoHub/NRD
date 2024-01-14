#!/bin/bash

# Define an array of news site URLs that provide RSS feeds for military news
declare -a NEWS_SITES=(
    "https://www.aljazeera.com/xml/rss/all.xml"
    "https://rss.nytimes.com/services/xml/rss/nyt/World.xml"
    "https://abcnews.go.com/abcnews/topstories"
    "https://feeds.nbcnews.com/nbcnews/public/news"
    "https://feeds.a.dj.com/rss/RSSWorldNews.xml"
    "https://www.pbs.org/newshour/feeds/rss/headlines"
    "https://feeds.feedburner.com/euronews/en/news/"
    "https://foreignpolicy.com/feed/"
    "https://feeds.bbci.co.uk/news/uk/rss.xml"
    "https://feeds.skynews.com/feeds/rss/uk.xml"
    "https://www.independent.co.uk/news/world/rss"
    "https://www.theguardian.com/world/rss"
    "https://www.lemonde.fr/international/rss_full.xml"
    "https://www.scmp.com/rss/91/feed"
    "https://www.aljazeera.com/xml/rss/all.xml"
    "https://www.koreatimes.co.kr/www/rss/world.xml"
    "https://www.straitstimes.com/news/world/rss.xml"
    "https://news.un.org/feed/subscribe/en/news/all/rss.xml"
    "https://themessenger.com/rss/default.xml"
    "http://rss.cnn.com/rss/edition_world.rss"
    "https://globalnews.ca/feed/"
    "https://www.dailytelegraph.com.au/news/world/rss"
    "https://nationalpost.com/feed"
    "https://www.france24.com/en/rss"
    "https://www.rt.com/rss/"
    "https://www.pravda.com.ua/rss/view_news/"
    "https://chaski.huffpost.com/us/auto/vertical/world-news"
    "https://search.cnbc.com/rs/search/combinedcms/view.xml?partnerId=wrss01&id=100003114"
    "https://www.latimes.com/world-nation/rss2.0.xml#nt=0000016c-0bf3-d57d-afed-2fff84fd0000-1col-7030col1"
    "https://feeds.a.dj.com/rss/RSSWorldNews.xml"
    "https://feeds.washingtonpost.com/rss/world"
    "https://news.google.com/rss?hl=no&gl=NO&ceid=NO:no"
    "https://feeds.feedburner.com/ndtvnews-world-news"
    "https://www.nasa.gov/news-release/feed/"
    "https://www.space.com/feeds/all"
)

declare -a DANISH_NEWS_SITES=(
        "https://www.dr.dk/nyheder/service/feeds/allenyheder"
        "https://www.tv2fyn.dk/rss"
        "https://www.tv2ostjylland.dk/rss"
        "https://www.tv2nord.dk/rss"
        "https://www.tv2east.dk/rss"
)

# Create a full news report file
FULL_NEWS_REPORT="index.html"
touch "$FULL_NEWS_REPORT"

# Function to fetch and format news from each site
fetch_news() {
    local url="$1"
    local news_data
    echo "Collecting news from $url..."
    # Fetch and parse the RSS feed, extracting titles and links
    news_data=$(curl -s "$url" | xmlstarlet sel -t -m '//item' -v 'concat(title, "||", link)' -n)
    echo "$news_data"
}

# Start HTML report
cat > "$FULL_NEWS_REPORT" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>News Report - $(date +%Y-%m-%d)</title>
    <style>
        body {
            text-align: center;
            background-color: #09133b;
        }
        h1 {
            margin-top: 50px;
            color: #ffffff;
        }
        h2 {
            color: #ffffff; 
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin: 5px 0;
        }
        li a {
            font-size: larger; /* Make the links text size larger */
            color: #d7dadc; /* Optional: change link color for better readability */
        }
    </style>
</head>
<body>
    <h1>News Report - $(date +%Y-%m-%d)</h1>
EOF

# Function to extract domain from URL
extract_domain() {
    local url=$1
    # Extract the domain part of the URL
    echo "$url" | awk -F/ '{print $3}'
}

# Loop over NEWS_SITES and collect the fetched news
for site in "${NEWS_SITES[@]}"; do
    news_items=$(fetch_news "$site")
    domain=$(extract_domain "$site")
    echo "<h2>$domain</h2>" >> "$FULL_NEWS_REPORT"
    echo "<ul>" >> "$FULL_NEWS_REPORT"
    IFS=$'\n'
    first_item=true
    for item in $news_items; do
        if [ "$first_item" = true ]; then
            first_item=false
            continue
        fi
        title=${item%||*}
        link=${item#*||}
        echo "<li><a href=\"$link\">$title</a></li>" >> "$FULL_NEWS_REPORT"
    done
    echo "</ul>" >> "$FULL_NEWS_REPORT"
    unset IFS
done

# Loop over DANISH_NEWS_SITES and collect the fetched news
for site in "${DANISH_NEWS_SITES[@]}"; do
    news_items=$(fetch_news "$site")
    domain=$(extract_domain "$site")
    echo "<h2>$domain</h2>" >> "$FULL_NEWS_REPORT"
    echo "<ul>" >> "$FULL_NEWS_REPORT"
    IFS=$'\n'
    first_item=true
    for item in $news_items; do
        if [ "$first_item" = true ]; then
            first_item=false
            continue
        fi
        title=${item%||*}
        link=${item#*||}
        echo "<li><a href=\"$link\">$title</a></li>" >> "$FULL_NEWS_REPORT"
    done
    echo "</ul>" >> "$FULL_NEWS_REPORT"
    unset IFS
done

# End HTML report
cat >> "$FULL_NEWS_REPORT" <<EOF
</body>
</html>
EOF

# Display path to full news report
echo "Full news report generated at: $FULL_NEWS_REPORT"

sleep 5

bash ./Docker-Up.sh
