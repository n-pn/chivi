require "./spec_helper"
require "../../src/appcv/models/author.cr"

describe CV::Author do
  Spec.before_each do
    Author.clear
  end
end
