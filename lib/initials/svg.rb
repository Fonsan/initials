module Initials
  class SVG
    HUE_WHEEL = 360

    DEFAULT_FONT_STYLE = "style='font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, Oxygen-Sans, Ubuntu, Cantarell, \"Helvetica Neue\", sans-serif; user-select: none;'"

    attr_reader :name, :colors, :limit, :shape, :size

    def initialize(name, colors: 12, limit: 3, shape: :circle, size: '100%', default_font: false)
      @name = name.to_s.strip
      @colors = colors
      @limit = limit
      @shape = shape
      @size = size
      @default_font = default_font

      raise Initials::Error.new("Colors must be a divider of 360 e.g. 24 but not 16.") unless valid_colors?
      raise Initials::Error.new("Size is not a positive integer.") unless valid_size?
    end

    def name
      @name.empty? ? "?" : @name
    end

    def to_s
      svg = [
        "<svg width='#{size}' height='#{size}' preserveAspectRatio='xMinYMid meet' viewBox='0 0 2000 2000'>",
          shape == :rect ?
            "<rect width='#{size}' height='#{size}' fill='#{fill}' />"
          :
            "<circle cx='50%' cy='50%' r='50%' fill='#{fill}' />",
          "<text x='50%' y='52%' fill='white' font-size='1300' letter-spacing='-100' fill-opacity='0.75' dominant-baseline='central' text-anchor='middle' #{DEFAULT_FONT_STYLE if @default_font}>",
            "#{initials}",
          "</text>",
        "</svg>"
      ].join

      svg.html_safe rescue svg
    end

    def fill
      return "hsl(0, 0%, 67%)" if @name.empty?

      hue_step = HUE_WHEEL / colors
      char_sum = name.split("").sum do |c|
        # Multiplication makes sure neighboring characters (like A and B) are one hue step apart.
        c.ord * hue_step
      end

      # Spin the wheel!
      hue = char_sum % HUE_WHEEL

      "hsl(#{hue}, 40%, 40%)"
    end

    def initials
      @initials ||= name.split(' ')[0, limit].map { |s| s[0].capitalize }.join
    end

    private

    def valid_font_size_multiplier?
      (0..2) === @font_size_multiplier
    end

    def valid_colors?
      return false unless colors.respond_to?(:to_i)
      return false unless colors > 0
      HUE_WHEEL % colors == 0
    end

    def valid_size?
      return false unless size.respond_to?(:to_i)
      size.to_i > 0
    end
  end
end
