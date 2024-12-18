echo $(LC_ALL=C tr -dc 'A-Z1-9' < /dev/urandom | \
tr -d "1IOS5U" | fold -w 48 | sed "-es/./ /"{1..26..5} | \
cut -c2- | tr " " "-" | head -1) ;