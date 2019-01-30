---
layout: default
---

<section class="posts">
  {% for post in site.posts %}
  <article>
    <header>
      <h2><a href="{{ post.url }}">{{ post.title }}</a></h2>
      <p>Posted on <time datetime="{{ page.date | date: "%Y-%m-%dT%H:%M:%SZ" }}">{{ page.date | date: "%B %e, %Y" }}</time></p>
    </header>
    <p>{{ post.excerpt }} <a href="{{ post.url }}" class="continue-reading">Continue reading &rarr;</a></p>
  </article>
  {% endfor %}
</section>
