require 'opal'
compiled_js = Opal.compile(File.read('finite_fields.rb'))
File.open('../public_html/finite_fields.js', 'w') { |f| f.write(compiled_js) }
