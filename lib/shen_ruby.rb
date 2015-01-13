require 'klam'
require 'shen_ruby/version'
require 'shen_ruby/converters'

module ShenRuby
  extend ShenRuby::Converters
end

# The following file is a derivative of the Shen release packages with ShenRuby
# and it located under the shen directory hierarchy to make the license
# unambigous. It can be found at shen/lib/shen_ruby/shen.rb
require 'shen_ruby/shen'
