# Be sure to restart your server when you modify this file.
#
# +grant_on+ accepts:
# * Nothing (always grants)
# * A block which evaluates to boolean (recieves the object as parameter)
# * A block with a hash composed of methods to run on the target object with
#   expected values (+votes: 5+ for instance).
#
# +grant_on+ can have a +:to+ method name, which called over the target object
# should retrieve the object to badge (could be +:user+, +:self+, +:follower+,
# etc). If it's not defined merit will apply the badge to the user who
# triggered the action (:action_user by default). If it's :itself, it badges
# the created object (new user for instance).
#
# The :temporary option indicates that if the condition doesn't hold but the
# badge is granted, then it's removed. It's false by default (badges are kept
# forever).

module Merit
  class BadgeRules
    include Merit::BadgeRulesMethods

    def initialize
      award_user_who :is_alpha_user, "alpha-user"
      award_user_who :is_beta_user,  "beta-user"
      award_user_who :is_developer,  "omega"
      award_user_who :is_new_user,   "new-user", temporary: true
      award_user_who :has_completed_profile_information, 'autobiographer', temporary: true
    end

    private

    def award_user_who(check, badge, options = {}, &block)
      actions = ['users/sessions#create', 'users#update', 'users/sessions#destroy']
      actions.push [options.delete(:and_on)]

      grant_on actions.flatten.compact, {
        badge: badge,
        model_name: "User",
        to: :itself
      }.merge(options) do |user|
        user.send("#{check}?")
      end
    end
  end
end
