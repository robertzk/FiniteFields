if (!console || !console.log) (console = {}).log = function() {} // IE

function getQueryVariable(variable) {
  var query = window.location.search.substring(1);
  var vars = query.split('&');
  for (var i = 0; i < vars.length; i++) {
      var pair = vars[i].split('=');
      if (decodeURIComponent(pair[0]) == variable) {
          return decodeURIComponent(pair[1]);
      }
  }
  console.log('Query variable %s not found', variable);
}
var symbol = getQueryVariable('symbol') || 'x';

window.onload = function() {
  var button = document.getElementById('generate')
  $("form").on('submit', function(e) {
    prime = parseInt(document.getElementById('prime').value, 10)
    exponent = parseInt(document.getElementById('exponent').value, 10)
    if (isNaN(prime) || isNaN(exponent) || prime < 2 || exponent < 1) {
      alert('Please enter positive integers')
      e.preventDefault()
      return(false)
    }
    if (exponent > 10 || prime > 100 || Math.pow(prime, exponent) > 1000) {
      alert('You should know better. There is no way your poor little computer could handle that number. ;)')
      e.preventDefault()
      return(false)
    }
    document.getElementById('mt').innerHTML = 'Loading...'
    setTimeout(function() {
      var ff = Opal.FiniteField.$new(prime,exponent)
      var mt = ff.$multiplication_table(false)
      if (symbol != 'x') mt = mt.replace(/x/gi, symbol)
      document.getElementById('mt').innerHTML = mt
    }, 100)
    var url = window.location.href.replace(/\?.*/, '') + '?'
    url = url + $.map({ prime: prime, exponent: exponent, symbol: symbol },
      function (value, key) {
        return encodeURIComponent(key) + '=' + encodeURIComponent(value)
      }).join('&')
    if (history.pushState) history.pushState('data', '', url)
    e.preventDefault()
    return false;
  })
  $("#prime").val(getQueryVariable('prime') || 5)
  $("#exponent").val(getQueryVariable('exponent') || 2)
  $("form").submit()
  var get_index = function(td) {
    return $.inArray(td[0], td.parent().children())
  }
  $("#mt").delegate('tbody td', 'mouseover', function(e) {
    var td = $(e.target)
    var x_index = get_index(td)
    var y_index = get_index(td.parent('tr'))
    if (x_index >= 1 && y_index >= 0) {
      $("#mt tbody tr:nth-child(" + (y_index+1) + ") td, #mt tr td:nth-child(" + (x_index+1) + ")").addClass('selected')
    }
  }).delegate('tbody td', 'mouseout', function(e) {
    $("#mt td.selected").removeClass('selected')
  })
}
