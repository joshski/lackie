module Lackie
  class CacheBuster
    def self.unique_string
      @@unique_number ||= 0
      (@@unique_number += 1).to_s
    end
  end
end