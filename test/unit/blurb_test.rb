require File.dirname(__FILE__) + '/../test_helper'
require "shoulda"

class BlurbTest < ActiveSupport::TestCase

  context "blurb created with bad stuff" do
    setup do
      @blurb = Blurb.new(:key => "test",
        :title => "Title <javascript>bad stuff</javascript>With Javascript",
        :body => "<div style='ontop'>Cover up stuff</div>")
      @blurb.valid?
    end
    should "not have bad stuff in title" do
      assert_no_match %r{<javascript>bad stuff</javascript>}, @blurb.title
    end
    should "not have bad stuff in body" do
      assert_no_match %r{<div style='ontop'>Cover up stuff</div>}, @blurb.body
    end
  end
end
