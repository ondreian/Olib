require "json"
require "Olib/psycellium/dsl"

module Psycellium
  ##
  ## 
  ##
  class Message
    def self.from_string(str)
      new(JSON.parse(str).reduce({}) do |m, (key, val)|
        m[key.to_sym] = val
        m
      end)
    end

    attr_accessor :to, :inbox, :data, :type, :from, :uuid

    def initialize(data)
      @uuid  = data[:uuid] ||= SecureRandom.uuid
      @inbox = data[:inbox].to_sym unless data[:inbox].nil?
      @to    = data[:to]
      @from  = data[:from]
      @type  = data[:type]
      @data  = data[:data]
    end

    def to_s
      s = "<#{self.class.name} "
      s.concat "uuid=#{@uuid} "
      s.concat "to=#{@to} "       unless @to.nil?
      s.concat "data=#{@data} "   unless @data.nil?
      s.concat "inbox=#{@inbox} " unless @inbox.nil?
      s.concat "from=#{@from} "   unless @from.nil?
      s.concat "type=#{@type} "
      s.strip.concat ">"
    end

    def to_json
      self.instance_variables.reduce({}) do |m, attribute|
        val = self.instance_variable_get(attribute)
        m[attribute[1..-1]] = val unless val.nil?
        m
      end.to_json
    end

    def respond(data)
      self.class.new(
        type: DSL::RESPONSE,
        to: @from,
        uuid: @uuid,
        data: data,
      )
    end
  end
end