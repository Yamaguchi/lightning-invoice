module Lightning
  module Invoice
    class RoutingInfo
      attr_accessor :pubkey, :short_channel_id, :fee_base_msat, :fee_proportional_millionths, :cltv_expiry_delta

      def initialize(pubkey, short_channel_id, fee_base_msat, fee_proportional_millionths, cltv_expiry_delta)
        @pubkey = pubkey
        @short_channel_id = short_channel_id
        @fee_base_msat = fee_base_msat
        @fee_proportional_millionths = fee_proportional_millionths
        @cltv_expiry_delta = cltv_expiry_delta
      end

      def to_array
        pubkey.htb.unpack("C*") +
        short_channel_id.htb.unpack("C*") +
        Invoice.int_to_array(fee_base_msat, 5, 4) +
        Invoice.int_to_array(fee_proportional_millionths, 5, 4) +
        Invoice.int_to_array(cltv_expiry_delta)
      end
    end
  end
end