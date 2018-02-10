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
    end
  end
end