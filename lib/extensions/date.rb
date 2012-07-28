class Date

  class << self
    unless method_defined?(:day_fraction_to_time)
      SECONDS_IN_DAY = Rational(1, 86400)

      def day_fraction_to_time(fr)
        ss,  fr = fr.divmod(SECONDS_IN_DAY) # 4p
        h,   ss = ss.divmod(3600)
        min, s  = ss.divmod(60)
        return h, min, s, fr
      end
    end
  end
end
