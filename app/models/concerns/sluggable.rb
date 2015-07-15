module Sluggable
  extend ActiveSupport::Concern

  included do
    extend ::FriendlyId
    friendly_id :slug_candidates

    validates_presence_of :friendly_id
    # move validation errors to the slug field supplied or
    # to the first field among fields guessed by us.
    after_validation :move_friendly_id_errors_to_slug_field

    def slug_candidates
      [friendly_id_methods].flatten
    end

    private

    def move_friendly_id_errors_to_slug_field
      return if errors[:friendly_id].blank?

      base     = friendly_id_config.base
      guessed  = base == :slug_candidates
      supplied = self.class.column_names.include?(base)
      return unless supplied || guessed

      base = supplied ? base : friendly_id_methods.first
      errors.add base, *errors.delete(:friendly_id)
    end

    def friendly_id_methods
      fields = %w[username name title full_name full_title display_name to_s]
      fields.select{|field| self.class.method_defined?(field)}.map(&:to_sym)
    end
  end

  # class_methods do
  #   def slug_scoped_to(relation)
  #     friendly_id :slug_candidates, use: :scoped, scope: relation
  #   end
  # end
end
