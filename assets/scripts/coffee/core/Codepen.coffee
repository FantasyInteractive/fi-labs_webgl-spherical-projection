###
#============================================================
#
# Codepen utility class for dynamically building pens.
#
# @author Matthew Wagerfield
#
#============================================================
###

class Codepen

  ###
  #========================================
  # Class Variables
  #========================================
  ###

  @host = 'http://codepen.io'



  ###
  #========================================
  # Class Methods
  #========================================
  ###

  @buildURL = (host, user, href, type, height, safe) ->
    query = "?type=#{type}&height=#{height}&safe=#{safe}"
    url = [host, user, "embed", href + query].join "/"
    return url.replace /\/\//g, "//"

  @buildFrame = ($element) ->
    user = $element.data 'user'
    href = $element.data 'href'
    type = $element.data 'type'
    safe = $element.data 'safe'
    height = $element.data 'height'
    url = @buildURL @host, user, href, type, height, safe
    attributes =
      id: "cp_embed_#{href.replace "/", "_"}"
      src: url
      scrolling: "no"
      frameborder: "0"
      height: height
      allowTransparency: "true"
      class: "cp_embed_iframe"
      style: "width:100%; border:none; overflow:hidden;"
    markup = "<iframe "
    markup += """#{key}="#{value}" """ for key, value of attributes
    return markup + ">"
