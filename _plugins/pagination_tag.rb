class PaginationTag < Liquid::Tag
  WINDOW = 1

  def render(context)
    window = WINDOW
    return unless paginator = context['paginator']
    page = paginator['page']
    total_pages = paginator['total_pages']

    output = '<nav class="pagination">'

    if page > 1
      output << %(<a class="previous" href="#{path_for(page - 1)}" rel="previous">&larr; Previous</a>)
    else
      output << '<span class="disabled">&larr; Previous</span>'
    end

    if page > window
      if page == window + 1
        output << link_for(1)
      else
        (1..window).each do |i|
          output << link_for(i)
        end

        if page > (window * 2) + 1
          output << gap
        end
      end
    end

    if page > 2
      output << %(<a href="#{path_for(page - 1)}" rel="prev">#{page - 1}</a>)
    end

    output << %(<span class="current">#{page}</span>)

    if page < total_pages - 1
      output << %(<a href="#{path_for(page + 1)}" rel="next">#{page + 1}</a>)
    end

    if page <= total_pages - window
      if page == total_pages - window
        output << link_for(total_pages)
      else
        if page < total_pages - window * 2
          output << gap
        end

        ((total_pages - window + 1)..total_pages).each do |i|
          output << link_for(i)
        end
      end
    end

    if page < total_pages
      output << %(<a class="next" href="#{path_for(page + 1)}" rel="next">Next &rarr;</a>)
    else
      output << '<span class="disabled">Next &rarr;</span>'
    end

    output << '</nav>'
    output
  end

  private

  def link_for(page)
    %(<a href="#{path_for(page)}">#{page}</a>)
  end

  def path_for(page)
    return '/' if page == 1
    "/#{page}"
  end

  def gap
    '<span class="gap">&hellip;</span>'
  end
end

Liquid::Template.register_tag('pagination', PaginationTag)
