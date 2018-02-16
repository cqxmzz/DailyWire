#! /usr/bin/env python
# -*- coding: utf-8 -*-
# encoding=utf8

#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, write to the Free Software Foundation, Inc., 51 Franklin
# St, Fifth Floor, Boston, MA 02110-1301 USA

VERSION="0.1"

import urllib2
import feedparser
import sys
import requests
import json
from random import choice
from xml.sax.saxutils import escape
from BeautifulSoup import BeautifulSoup
from HTMLParser import HTMLParser


reload(sys)
sys.setdefaultencoding('utf8')
feedparser.USER_AGENT = "FeedNotify/%s +http://burtonini.com/" % VERSION
h = HTMLParser()

feeds = []
testing = False

class Feed:
    def __init__(self, title, url):
        self.title = title
        self.url = url
        self.seen = []
	self.firstTime = not testing

    def prettifyStr(self, s):
        soup = BeautifulSoup(s)
        return unicode(h.unescape(soup.text))

    def parse(self, feed):
        items = []
#    {
#       'title': u'Is Faith Gaining Ground In American Music?',
#       'summary': u'What do Alice Cooper, Chance the Rapper?',
#       'link': u'https://www.dailywire.com/news/26783/faith-toto',
#       'author': u'Christian Toto',
#       'id': u'http://www.dailywire.com/node/26783'
#    }
        for entry in feed.entries:
            if entry.id not in self.seen:
                self.seen.append(entry.id)

                if not self.firstTime:
                    items.append({
                        "title": self.prettifyStr(entry.title),
                        "summary": self.prettifyStr(entry.summary),
                        "link": entry.link,
                        "author": self.prettifyStr(entry.author),
                        "id": entry.id,
                    })
        self.firstTime = False
        self.seen = self.seen[-100:]

        for item in items:
            link = item["link"]
            media = ""
            author = item["author"]
            content = item["title"]
            title = ""

            if author == u"Ben Shapiro":
                title = "Ben Shapiro Article:"

            divide = -1
            divide1 = content.find(':')
            divide2 = content.find('!')
            if divide is -1 or divide1 < divide:
                divide = divide1
            if divide is -1 or divide2 > 0 and divide2 < divide:
                divide = divide2
            if not len(title) and divide is not -1 and divide <= 20 and divide >= 3:
                if not any(c.islower() for c in content[:divide+1]):
                    if sum(1 for _ in (c.isupper() for c in content[:divide+1])) > divide / 2:
                        title = content[:divide+1].strip()
                        content = content[divide+1:].strip()
            opener = urllib2.build_opener()
            opener.addheaders = [('User-Agent', 'Mozilla/5.0')]
            response = opener.open(link)
            htmlSource = response.read()
            response.close()
            htmlSoup = BeautifulSoup(htmlSource)

            figures = htmlSoup.findAll('figure')
            for figure in figures:
                if figure["class"] == "media":
                    src = figure.findAll('img')[0]["src"]
                    idx = src.find(".jpg")
                    if idx > 0:
                        media = src[:idx+4]
                        break
                    idx = src.find(".jpeg")
                    if idx > 0:
                        media = src[:idx+5]
                    break

            if media == "":
                ass = htmlSoup.findAll('a', href=True)
                for a in ass:
                    if a["href"].find("podcasts/show/") >= 0:
                        style = a["style"]
                        title = a.getText()
                        media = "https://www.dailywire.com" + style[style.find("(")+1:style.find(")")]
                        break

            header = {
                "Content-Type": "application/json; charset=utf-8",
                "Authorization": "Basic M2FjZDU4MDYtMWJkNi00YzRkLTg0ODMtMjZjN2FlMmYwZDE2"
            }
            payload = {
                "app_id": "f3d65f86-40a9-4943-b76c-ddf547e983cd",
                "included_segments": ["All"],
                "contents": {
                    "en": content
                },
                "headings": {
                    "en": title
                },
                "data": {
                    "url": link
                },
                "ios_attachments": {
                    "pic1": media
                },
                "ios_badgeType": 'Increase',
                "ios_badgeCount": 1
            }
            req = requests.post("https://onesignal.com/api/v1/notifications", headers=header, data=json.dumps(payload))
            print(item["title"])
            print(req.status_code, req.reason)

    def run(self):
        feed = feedparser.parse(self.url, etag=None, modified=None)
        self.parse(feed)


if __name__ == "__main__":
    import sys, time

    if sys.argv[1:]:
        for url in sys.argv[1:]:
            feeds.append(Feed("Test", url))
    else:
        feeds.append(Feed("DailyWire", "https://www.dailywire.com/rss.xml"))

    while True:
        [feed.run() for feed in feeds]
        time.sleep(60)
