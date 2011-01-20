require 'spec_helper'

CONFIG = {
  :app_id => 12345,
  :secret => 'mysecret',
  :domain => 'example.org'
}

BOOKIES = "\"access_token=12345|2.1reallylongnonsense__.3600.1275001200-8008|somelong_messof-garbage.&base_domain=example.com&expires=1275001200&secret=my_magic_secretthingy__&session_key=2.1reallylongnonsense__.3600.1275001200-8008&sig=7aba93541ca96c5d3cc5dec3ee305de9&uid=8008\""

BAD_SIG = BOOKIES.sub(/sig=[^&]+/, 'johnhancock')

COOKIES = {'sometimes_food' => true, 'fbs_12345' => BOOKIES}


def build_bookies(content)
  Bookies.new(content, CONFIG[:app_id], CONFIG[:secret], CONFIG[:domain])
end

describe Bookies do
  it "parses properly" do
    bookies = Bookies.parse(BOOKIES)
    bookies.should be_a(Hash)
    bookies[:uid].should == 8008
  end

  it "pulls the Facebook cookies out of the rest" do
    bookies = build_bookies(COOKIES)
    bookies[:uid].should == 8008
  end

  it "handles empty input" do
    build_bookies(nil).should be_empty
    build_bookies('').should  be_empty
    build_bookies({}).should  be_empty
  end

  it "rejects unsigned cookies" do
    build_bookies(BAD_SIG).should be_empty
  end

  it "can clear Facebook-related cookies" do
    bookies = build_bookies(COOKIES)
    COOKIES.should_receive(:delete).
      with("fbs_#{CONFIG[:app_id]}", :domain => CONFIG[:domain])
    bookies.clear!
    bookies.should be_empty
  end
end
