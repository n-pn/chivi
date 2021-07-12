require "./spec_helper"
require "../../src/appcv/zhseed.cr"

describe CV::Zhseed do
  Spec.before_each do
    Zhseed.clear
  end
end
