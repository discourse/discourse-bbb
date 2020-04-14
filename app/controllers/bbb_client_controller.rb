# frozen_string_literal: true

require 'digest/sha1'

module BigBlue
  class BbbClientController < ApplicationController
    before_action :ensure_logged_in

    def create
      render json: {
        url: create_and_join(params)
      }
    end

    def status
      render json: get_status(params)
    end

    private

    def create_and_join(args)
      return false unless SiteSetting.bbb_endpoint && SiteSetting.bbb_secret

      meeting_id = args['meetingID']
      attendee_pw = args['attendeePW']
      moderator_pw = args['moderatorPW']

      query = {
        meetingID: meeting_id,
        attendeePW: attendee_pw,
        moderatorPW: moderator_pw,
        logoutURL: Discourse.base_url
      }.to_query

      create_url = build_url("create", query)
      response = Excon.get(create_url)

      if response.status != 200
        Rails.logger.warn("Could not create meeting: #{response.inspect}")
        return false
      end

      join_params = {
        fullName: current_user.name || current_user.username,
        meetingID: meeting_id,
        userID: current_user.username,
        password: is_moderator ? moderator_pw : attendee_pw
      }.to_query

      build_url("join", join_params)
    end

    def get_status(args)
      return {} unless SiteSetting.bbb_endpoint && SiteSetting.bbb_secret

      url = build_url("getMeetingInfo", "meetingID=#{args['meeting_id']}")
      response = Excon.get(url)
      data = Hash.from_xml(response.body)

      if data['response']['returncode'] == "SUCCESS"
        att = data['response']['attendees']['attendee']
        usernames = att.is_a?(Array) ? att.pluck("userID") : [att["userID"]]
        users = User.where("username IN (?)", usernames)

        avatars = users.map do |s|
          {
            name: s.name || s.username,
            avatar_url: s.avatar_template_url.gsub('{size}', '25')
          }
        end

        {
          count: data['response']['participantCount'],
          avatars: avatars
        }
      else
        {}
      end
    end

    def build_url(type, query)
      secret = SiteSetting.bbb_secret
      checksum = Digest::SHA1.hexdigest(type + query + secret)
      "#{SiteSetting.bbb_endpoint}#{type}?#{query}&checksum=#{checksum}"
    end

    def is_moderator
      return true if current_user.staff?

      group = SiteSetting.bbb_moderator_group_name
      return true if group.present? && current_user.groups.pluck(:name).include?(group)
    end
  end
end
