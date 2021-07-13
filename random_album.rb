# frozen_string_literal: true

require 'active_support/all'
require 'byebug'
require 'httparty'

class RssSource
  def url
    raise 'Redefine this'
  end

  def process(xml_hash)
    element_list(xml_hash).map { |element| process_element(element) }
  end

  def download
    HTTParty.get(url).to_s
  end

  def album_list
    process(Hash.from_xml(download))
  end

  def element_list(xml_hash)
    xml_hash['rss']['channel']['item']
  end

  def process_element(xml_hash_element)
    xml_hash_element['title']
  end
end

class Metacritic < RssSource
  def url
    'https://www.metacritic.com/rss/music'
  end
end

class Pitchfork < RssSource
  def url
    'https://pitchfork.com/feed/feed-album-reviews/rss'
  end

  def process_element(xml_hash_element)
    "#{xml_hash_element['link'].gsub('https://pitchfork.com/reviews/albums/', '')} - #{xml_hash_element['title']}"
  end
end

class MusicOmh < RssSource
  def url
    'http://www.musicomh.com/feed'
  end
end

class TheGuardian < RssSource
  def url
    'https://www.theguardian.com/music+tone/albumreview/rss'
  end
end

class MetalInjection < RssSource
  def url
    'https://metalinjection.net/category/reviews/rss'
  end
end

puts [MetalInjection, TheGuardian, Pitchfork, MusicOmh].map { |a| a.new.album_list }.flatten.compact.sample(3)
