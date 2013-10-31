require_relative '../lib/node'
require 'sinatra/base'
require 'json'

module Automaton
  class ENC < Sinatra::Base

    configure :production, :development do
      enable :logging
    end

    get '/node' do
      content_type :json
      node = Automaton::Node::new({ :node => params[:name],
                                    :enc => {
                                        :environment => params[:environment],
                                        :classes     => params[:classes],
                                        :parameters  => params[:parameters]
                                    },
                                    :inherit => params[:inherits]
                                   }).lookup
      if node == 'not_found'
        logger.error "Node >#{ params[:name] }< NOT Found in ENC"
        body "ERROR: Node >#{ params[:name] }< NOT Found in ENC"
        status 404
      else
        body node.to_json
        status 200
      end
    end

    post '/node/add' do
      node = Automaton::Node::new({ :node => params[:name],
                                    :enc => {
                                        :environment => params[:environment],
                                        :classes     => params[:classes],
                                        :parameters  => params[:parameters]
                                    },
                                    :inherit => params[:inherits]
                                  }).add
      if node == 'existing_entry'
        status 404
        logger.error "Node >#{ params['name'] }< already exists in the ENC"
        body "ERROR: Node >#{ params['name'] }< already exists in the ENC"
      else
       status 200
       logger.info "Node >#{ params[:name] }< Added to the ENC"
       body "Node >#{ params[:name] }< Added to the ENC"
      end
    end

    post '/node/update' do
      begin
        node = Automaton::Node::new({ :node => params[:name],
                                      :enc => {
                                          :environment => params[:environment],
                                          :classes     => params[:classes],
                                          :parameters  => params[:parameters]
                                      },
                                      :inherit => params[:inherits]
                                    }).update
        logger.info "Node >#{ params[:name] }< has been updated"
        body "Node >#{ params[:name] }< has been updated"
        status 200
      rescue
        status 404
        logger.error "Node >#{ params[:name] }< NOT Found in ENC"
        body "ERROR: Node >#{ params[:name] }< NOT Found in ENC"
      end
    end

    post '/node/remove' do
      content_type :text
      node = Automaton::Node::new({ :node => params[:name],
                                    :enc => {
                                        :environment => params[:environment],
                                        :classes     => params[:classes],
                                        :parameters  => params[:parameters]
                                    },
                                    :inherit => params[:inherits]
                                  }).remove
      if node == 'not_found'
        status 404
        logger.error "Node >#{ params[:name] }< NOT Found in ENC"
        body "ERROR: Node >#{ params[:name] }< NOT Found in ENC"
      else
        status 200
        logger.info "Node >#{ params[:name] }< REMOVED from the ENC"
        body "Node >#{ params[:name] }< REMOVED from the ENC"
      end
    end
    run! if app_file == $0
  end
end