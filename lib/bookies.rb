class Bookies
  def initialize(cookies, app_id, app_secret, domain)
    @cookies = cookies
    @app_id = app_id
    @app_secret = app_secret
    @domain = domain
    @bookies = parsed_cookies
  end

  def [](name)
    return nil unless @bookies && valid?
    @bookies[name]
  end

  def inspect
    @bookies.inspect
  end

  def clear!
    @cookies.delete self.class.fb_cookie_key(@app_id), :domain => @domain
  end

  private

  def self.fb_cookie_key(app_id)
    "fbs_#{app_id}"
  end

  def self.parse(str)
    return HashWithIndifferentAccess.new if str.blank?
    bookies = HashWithIndifferentAccess.new
    # The sub is just lchomp, if only that existed
    str.chomp('"').sub(/^"/, '').split('&').each do |kv|
      key, value = kv.split('=')
      bookies[key] = value
    end
    %w[expires uid].each {|key| bookies[key] = bookies[key].to_i}
    bookies
  end

  def parsed_cookies
    self.class.parse(@cookies[self.class.fb_cookie_key(@app_id)])
  end

  def valid?
    generated_signature == given_signature
  end

  def generated_signature
    Digest::MD5.hexdigest(payload + @app_secret)
  end

  def payload
    signable.map{|k, v| "#{k}=#{v}"}.join
  end

  def signable
    @bookies.reject{|k, v| k == 'sig'}.sort_by{|k, v| k}
  end

  def given_signature
    @bookies[:sig]
  end
end