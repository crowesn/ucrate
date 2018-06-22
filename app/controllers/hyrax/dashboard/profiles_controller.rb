# frozen_string_literal: true

require Hyrax::Engine.root.join('app/controllers/hyrax/dashboard/profiles_controller.rb')
module Hyrax
  module Dashboard
    class ProfilesController < Hyrax::UsersController
      private

        def user_params
          params.require(:user).permit(:avatar, :facebook_handle, :twitter_handle,
                                       :googleplus_handle, :linkedin_handle, :remove_avatar,
                                       :orcid, :first_name, :last_name, :title, :ucdepartment, :uc_affiliation,
                                       :alternate_email, :telephone, :alternate_phone_number, :website, :blog)
        end
    end
  end
end
