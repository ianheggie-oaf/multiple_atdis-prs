#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH << "./lib"

require "atdisplanningalertsfeed"

AUTHORITIES = {
  armidale: {
    url: "https://epathway.newengland.nsw.gov.au/ePathway/Production/WebServiceGateway/atdis/1.0"
  },
  bathurst: {
    url: "http://masterview.bathurst.nsw.gov.au/atdis/1.0/"
  }
}.freeze

exceptions = []
AUTHORITIES.each do |authority_label, params|
  puts "\nCollecting ATDIS feed data for #{authority_label}..."

  begin
    # All the authorities are in NSW (for ATDIS) so they all have
    # the Sydney timezone
    ATDISPlanningAlertsFeed.fetch(params[:url], "Sydney", params[:ignore_ssl_certificate]) do |record|
      record[:authority_label] = authority_label.to_s
      puts "Storing #{record[:council_reference]} - #{record[:address]}"
      ScraperWikiMorph.save_sqlite(%i[authority_label council_reference], record)
    end
  rescue StandardError => e
    warn "#{authority_label}: ERROR: #{e}"
    warn e.backtrace
    exceptions << e
  end
end

raise "There were earlier errors. See output for details" unless exceptions.empty?
