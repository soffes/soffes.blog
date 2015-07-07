---
cover_image: cover.jpg
tags:
- personalsam
- podcast
---

# Personal Sam

After watching [Particle Fever](http://particlefever.com), I got inspired to do a [daily video journal thing](http://personalsam.com "Personal Sam"). Particle Fever is a documentary about the [Large Hadron Collider](http://en.wikipedia.org/wiki/Large_Hadron_Collider) (which is super interesting). They had video from some of the scientists’ daily video journals over the years of working on it. It was really cool to watch.

I got inspired and thought it would be fun to do my own. Not that any of my work is anywhere near as meaningful as theirs, it’s still fun to just do it. I’ve found it’s really enjoyable to summarize what I’m doing each day. I was surprised how much it effect my focus day to day.

Personal Sam is named after a Twitter account I used to have. My friend [Aaron Marshall](https://twitter.com/aaronmarshall), [Over](http://madewithover.com)’s founder, used to have @personalaaron. It was just him complaining about his boss and whatnot. I thought it was awesome and started @personalsam. It was mainly me winning about girls and how emo my life was back in 2008. Anyway, it seemed like a fitting name for my podcast thing and I already had the domain.

## Production

I usually shoot it in QuickTime Player on my iMac in the mornings and upload straight to Vimeo from there. I always do it one take and just hit share. On Vimeo’s website, I fill out all of the metadata. From there, all I have to do is add that video’s ID to the little [Rails app](https://github.com/soffes/personalsam.com) I made for it.

## Server

The web app hits [Vimeo’s API](http://developer.vimeo.com) and pulls down all of the meta data to populate the podcast feed. It’s all very simple. The download links hit a [proxy service](https://github.com/soffes/download.personalsam.com) I wrote. That just tells [Mixpanel](http://mixpanel.com) that someone watched the video and redirects to the actual file.

## Thoughts

==It’s funny to me that people actually watch it.== I started it just for me. It does feel pretty good that people care enough about the boring parts of my life to watch me talk at my computer. A nice side effect of doing this is I’m more motivated to get up early and get it out of the way. Anyway, if you’re interested, check out [PersonalSam.com](http://personalsam.com).
