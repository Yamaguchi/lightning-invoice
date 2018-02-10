require "lightning/invoice/version"

require 'bech32'
require 'bitcoin'

module Lightning
  module Invoice
    autoload :RoutingInfo, 'lightning/invoice/routing_info'

    PREFIX = 'lnbc'
    MAX_LENGTH = 2 ** 64

    class Message
      attr_accessor :prefix, :amount, :multiplier
      attr_accessor :timestamp, :signature, :payment_hash, :description, :pubkey, :description_hash, :expiry, :min_final_cltv_expiry, :fallback_address, :routing_info

      def initialize
        @expiry = 3600
        @min_final_cltv_expiry = 9
        @routing_info = []
      end

      def to_bech32

      end
    end

    def self.parse(str)
      human, data_part = Bech32.decode(str, MAX_LENGTH)
      return nil unless human
      prefix, amount, multiplier = parse_human_readable(human)
      message = Message.new
      message.prefix = prefix
      message.amount = amount.to_i
      message.multiplier = multiplier
      message.timestamp =
        (data_part[0] << 30) |
        (data_part[1] << 25) |
        (data_part[2] << 20) |
        (data_part[3] << 15) |
        (data_part[4] << 10) |
        (data_part[5] <<  5) |
        data_part[6]
      tags = data_part[7...data_part.size - 104]
      index = 0
      while index < tags.size
        type = tags[index]
        data_length = (tags[index + 1].to_i << 5) + tags[index + 2].to_i
        data = tags[index + 3 ... index + 3 + data_length]
        index += 3 + data_length
        bytes = to_bytes(data)
        case type
        when 1
          message.payment_hash = bytes[0...64].pack("C*")
        when 13
          message.description = bytes.pack("C*")
        when 19
          message.pubkey = bytes[0...66].pack("C*")
        when 23
          message.description_hash = bytes[0...64].pack("C*")
        when 6
          message.expiry = to_int(data)
        when 24
          message.min_final_cltv_expiry = to_int(data)
        when 9
          address = to_bytes(data[1..-1])
          hex = address.pack("C*").unpack("H*").first
          case data[0]
          when 0
            message.fallback_address = Bitcoin::Script.to_p2wpkh(hex).to_addr
          when 17
            message.fallback_address = Bitcoin.encode_base58_address(hex, Bitcoin.chain_params.address_version)
          when 18
            message.fallback_address = Bitcoin.encode_base58_address(hex, Bitcoin.chain_params.p2sh_version)
          else
          end
        when 3
          offset = 0
          while offset < bytes.size
            message.routing_info << Lightning::Invoice::RoutingInfo.new(
              bytes[offset...offset + 33].pack("C*"),
              bytes[offset + 33...offset + 41].pack("C*"),
              to_int(bytes[offset + 41...offset + 45]),
              to_int(bytes[offset + 45...offset + 49]),
              to_int(bytes[offset + 49...offset + 51])
            )
            offset += 51
          end
        else
        end
      end
      message.signature = word_to_buffer(data_part[data_part.size - 104..-1], true)
      message
    end

    def self.parse_human_readable(human)
      human.scan(/^([a-zA-Z]+)(\d*)([munp]?)$/)&.first
    end

    def self.word_to_buffer(data, trim)
      buffer = convert(data, 5, 8)

      if trim && (data.size * 5 % 8 != 0)
        buffer = buffer[0...-1]
      end
      return buffer.pack("C*")
    end

    def self.convert(data, inbits, outbits)
      value = 0
      bits = 0
      max = (1 << outbits) - 1

      result = []
      n = data.length 
      n.times do |i|
        value = (value << inbits) | data[i]
        bits += inbits
        while bits >= outbits
          bits -= outbits
          result << ((value >> bits) & max)
        end
      end

      if bits > 0
        result << (value << (outbits - bits)) & max
      end

      return result
    end

    def self.to_int(data)
      data.inject(0) do |i, sum|
        sum + (i << 5)
      end
    end

    def self.to_bytes(data)
      buf = []
      (data.size.*5).times do |i|
        loc5 = (i / 5).to_i
        loc8 = i >> 3
        if i % 8 == 0
          buf[loc8] = 0
        end
        buf[loc8] |= ((data[loc5] >> (4 - (i % 5))) & 1) << (7 - (i % 8))
      end
      if data.size % 8 != 0
        buf = buf[0...-1]
      end
      buf
    end
  end
end
