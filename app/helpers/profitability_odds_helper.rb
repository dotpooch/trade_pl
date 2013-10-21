module ProfitabilityOddsHelper

  def table_header(_headers)
    headers  = _headers.inject(''){|html, header| html << th(header)}.html_safe
    row      =  tr(headers)#.html_safe
    thead(row)#.html_safe
  end

end

=begin

html_safe is needed for converting strings into html

<thead>
<tr>
<%= th('Day') %>_header
<%= th('Total') %>
<%= th('Positive') %>
<%= th('Negative') %>
<%= th('Even') %>
<%= th('Odds of Gain') %>
<%= th('Odds of Loss') %>
<%= th('Odds of Even') %>
<%= th('Average Gain') %>
<%= th('Average Loss') %>
<%= th('Expectancy') %>
</tr>
</thead>

 down vote accepted
	

Considering Rails 3:

html_safe actually "sets the string" as HTML Safe (it's a little more complicated than that, but it's basically it). This way, you can return HTML Safe strings from helpers or models at will.

h can only be used from within a controller or view, since it's from a helper. It will force the output to be escaped. It's not really deprecated, but you most likely won't use it anymore: the only usage is to "revert" an html_safe declaration, pretty unusual.

Prepending your expression with raw is actually equivalent to calling html_safe on it, but, just like h, is declared on a helper, so it can only be used on controllers and views.

Here's a nice explanation on how the SafeBuffers (the class that does the html_safe magic) work: http://yehudakatz.com/2010/02/01/safebuffers-and-rails-3-0/


=end
