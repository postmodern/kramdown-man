# frozen_string_literal: true

require 'kramdown'

# HACK: load our version of kramdown/converter/man.rb and not kramdown's
require_relative './converter/man'
require_relative './man/version'
