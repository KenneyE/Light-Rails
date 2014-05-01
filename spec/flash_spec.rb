require 'rails_lite'

describe Flash do
  let(:req) { WEBrick::HTTPRequest.new(:Logger => nil) }
  let(:res) { WEBrick::HTTPResponse.new(:HTTPVersion => '1.0') }
  let(:cook) { WEBrick::Cookie.new('_rails_lite_app_flash', { :xyz=> 'abc' }.to_json) }

  it "deserializes json cookie if one exists" do
    req.cookies << cook
    p cook
    flash = Flash.new(req)
    flash['xyz'].should == 'abc'
  end

  describe "#store_flash" do
    context "without cookies in request" do
      before(:each) do
        flash = Flash.new(req)
        flash['first_key'] = 'first_val'
        flash.store_flash(res)
      end

      it "adds new cookie with '_rails_lite_app_flash' name to response" do
        cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
        cookie.should_not be_nil
      end

      it "stores the cookie in json format" do
        cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
        JSON.parse(cookie.value).should be_instance_of(Hash)
      end
    end

    context "with cookies in request" do
      before(:each) do
        cook = WEBrick::Cookie.new('_rails_lite_app_flash', { pho: "soup" }.to_json)
        req.cookies << cook
      end

      it "reads the pre-existing cookie data into hash" do
        flash = Flash.new(req)
        flash['pho'].should == 'soup'
      end

      it "saves new and old data to the cookie" do
        flash = Flash.new(req)
        flash['machine'] = 'mocha'
        flash.store_flash(res)
        cookie = res.cookies.find { |c| c.name == '_rails_lite_app_flash' }
        h = JSON.parse(cookie.value)
        h['pho'].should == 'soup'
        h['machine'].should == 'mocha'
      end
    end
  end
end
