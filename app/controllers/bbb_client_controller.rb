# frozen_string_literal: true
require 'digest/sha1'

module BigBlue
  class BbbClientController < ApplicationController
    before_action :ensure_logged_in

    def create
      render json: {
        url: build_url(params)
      }
    end

    private

    def build_url(args)
      return false unless SiteSetting.bbb_endpoint && SiteSetting.bbb_secret

      meeting_id = args['meetingID']
      url = SiteSetting.bbb_endpoint
      secret = SiteSetting.bbb_secret
      attendee_pw = args['attendeePW']
      moderator_pw = args['moderatorPW']

      query = {
        meetingID: meeting_id,
        attendeePW: attendee_pw,
        moderatorPW: moderator_pw
      }.to_query

      checksum = Digest::SHA1.hexdigest ("create" + query + secret)

      create_url = "#{url}create?#{query}&checksum=#{checksum}"
      response = Excon.get(create_url)

      if response.status != 200
        Rails.logger.warn("Could not create meeting: #{response.inspect}")
        return false
      end

      join_params = {
        fullName: current_user.name || current_user.username,
        meetingID: meeting_id,
        password: attendee_pw # TODO: pass moderator username or staff as moderator?
      }.to_query

      join_checksum = Digest::SHA1.hexdigest ("join" + join_params + secret)
      "#{url}join?#{join_params}&checksum=#{join_checksum}"
    end
  end
end
