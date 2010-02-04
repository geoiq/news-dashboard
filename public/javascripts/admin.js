
jq(function() {
  
  // take the color of  a clicked color_pick swatch and set the value
  // of any sibling input field to the color contained in the rel attribute.
  jq('.color_pick a').click(function() {
    jq(this).closest("fieldset").find("input").val(jq(this).attr('rel'))
    return false
  })
  
})