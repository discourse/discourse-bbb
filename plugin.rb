# frozen_string_literal: true

# name: discourse-bbb
# about: Integrate BigBlueButton in Discourse.
# version: 1.0.0
# authors: Penar Musaraj
# url: https://github.com/pmusaraj/discourse-bbb

enabled_site_setting :bbb_enabled
register_svg_icon "fab-bootstrap"
register_svg_icon "video"

after_initialize do
  [
    "../app/controllers/bbb_client_controller",
  ].each { |path| require File.expand_path(path, __FILE__) }

  module ::BigBlue
    PLUGIN_NAME ||= "discourse-bbb".freeze

    class Engine < ::Rails::Engine
      engine_name BigBlue::PLUGIN_NAME
      isolate_namespace BigBlue
    end
  end

  BigBlue::Engine.routes.draw do
    post '/create' => 'bbb_client#create', constraints: { format: :json }
  end

  Discourse::Application.routes.append do
    mount ::BigBlue::Engine, at: "/bbb"
  end

end
