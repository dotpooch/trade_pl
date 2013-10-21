module BannerHelper

  # Returns the full title on a per-page basis.
  def full_title(_page)
    base = "Whetstone Analytics"
    _page.empty? ? base : "#{base} | #{_page}"
  end

  def title(page_title)
    content_for :title, page_title.to_s
  end

  def nav_bar(_label, _link = "#")
    list(link_to_unless_current _label, _link, class: " navbar-text active")
  end

end
