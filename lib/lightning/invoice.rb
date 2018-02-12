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
        @amount = -1
        @timestamp = 0
        @expiry = 3600
        @min_final_cltv_expiry = 9
        @routing_info = []
      end

      def to_bech32
        human = +''
        human << prefix
        human << amount.to_s if amount && amount > 0
        human << multiplier if multiplier
        data = []
        data += Invoice.int_to_array(timestamp)
        if payment_hash
          data += [1]
          data += [1, 20]
          data += Invoice.buffer_to_word(payment_hash)
        end
        if description
          data += [13]
          description_word = Invoice.buffer_to_word(description)
          data += Invoice.int_to_array(description_word.size)
          data += description_word
        end
        if pubkey
          data += [19]
          data += [1, 21]
          data += Invoice.buffer_to_word(pubkey)
        end
        if description_hash
          data += [23]
          data += [1, 20]
          data += Invoice.buffer_to_word(description_hash)
        end
        if expiry && expiry != 3600
          data += [6]
          expiry_word = Invoice.int_to_array(expiry)
          data += Invoice.int_to_array(expiry_word.size)
          data += expiry_word
        end
        if min_final_cltv_expiry && min_final_cltv_expiry != 9
          data += [24]
          min_final_cltv_expiry_word = Invoice.int_to_array(min_final_cltv_expiry)
          data += Invoice.int_to_array(min_final_cltv_expiry_word.size)
          data += min_final_cltv_expiry_word
        end
        if fallback_address
          data += [9]
          type = fallback_address_type(fallback_address)
          case type
          when 0
            _, data_part = Bech32.decode(fallback_address)
            data += Invoice.int_to_array(data_part.size)
            data += data_part
          when 17, 18
            decoded = Bitcoin::Base58.decode(fallback_address)
            decoded = decoded.htb[1...-4]
            decoded = Invoice.buffer_to_word(decoded)
            data += Invoice.int_to_array(decoded.size + 1)
            data << type
            data += decoded
          end
        end
        if routing_info && !routing_info.empty?
          data += [3]
          data += Invoice.int_to_array(82 * routing_info.size)
          tmp = []
          routing_info.each do |r|
            tmp += r.to_array
          end
          data += Invoice.buffer_to_word(tmp.pack("C*"))
        end
        data += Invoice.buffer_to_word(signature)
        Bech32.encode(human, data)
      end
      
      def fallback_address_type(fallback_address)
        address_types = {
          'lnbc' => [0, 5],
          'lntb' => [111, 196]
        }

        hrp, data = Bech32.decode(fallback_address)
        if hrp
          0
        else
          decoded = [Bitcoin::Base58.decode(fallback_address)].pack("H*").unpack("C*")
          if decoded[0] == address_types[prefix][0]
            17
          elsif decoded[0] == address_types[prefix][1]
            18
          end
        end
      end
    end

    def self.parse(str)
      human, data_part = Bech32.decode(str, MAX_LENGTH)
      return nil unless human
      prefix, amount, multiplier = parse_human_readable(human)
      message = Message.new
      message.prefix = prefix
      message.amount = amount.to_i if !amount&.empty?
      message.multiplier = multiplier
      message.timestamp = to_int(data_part[0...7])
      tags = data_part[7...data_part.size - 104]
      index = 0
      while index < tags.size
        type = tags[index]
        data_length = (tags[index + 1].to_i << 5) + tags[index + 2].to_i
        data = tags[index + 3 ... index + 3 + data_length]
        bytes = to_bytes(data)
        index += 3 + data_length
        case type
        when 1
          message.payment_hash = bytes[0...64].pack("C*")
        when 13
          message.description = bytes.pack("C*").force_encoding('utf-8')
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

    def self.buffer_to_word(buffer)
      words = convert(buffer.unpack('C*'), 8, 5)
      return words
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
        result << ((value << (outbits - bits)) & max)
      end

      return result
    end

    def self.to_int(data)
      data.inject(0) do |i, sum|
        sum + (i << 5)
      end
    end

    def self.int_to_array(i, bits = 5, padding = 2)
      array = []
      return [0] if i.nil? || i == 0
      while i > 0
        array << (i & (2**bits - 1))
        i = (i / (2**bits)).to_i
      end
      if padding > array.size
        array += [0] * (padding - array.size)
      end
      array.reverse
    end

    def self.to_bytes(data)
      buf = []
      (data.size * 5).times do |i|
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
