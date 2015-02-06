require 'spec_helper'
require 'sidekiq/testing'

describe Bellbro::Worker do
  before :each do
    Sidekiq::Testing.disable!
    clear_sidekiq
  end

  after :each do
    clear_sidekiq
    Sidekiq::Testing.fake!
  end

  describe "#jobs_in_flight_with_domain" do
    it "counts the number of enqueued jobs and active workers for a domain" do
      domain = "www.retailer.com"
      5.times { Bellbro::Worker.perform_async(domain: domain) }
      expect(Bellbro::Worker.jobs_in_flight_with_domain(domain).count).to eq(5)
    end
  end
end
