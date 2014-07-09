require 'adwords_api'

class ApplicationController < ActionController::Base

  before_filter :authenticate
  protect_from_forgery

  PAGE_SIZE = 50
  
  private

  # Returns the API version in use.
  def get_api_version()
    return :v201309
  end

  # Returns currently selected account.
  def selected_account()
    @selected_account ||= session[:selected_account]
    return @selected_account
  end

  # Sets current account to the specified one.
  def selected_account=(new_selected_account)
    @selected_account = new_selected_account
    session[:selected_account] = @selected_account
  end

  # Checks if we have a valid credentials.
  def authenticate()
    token = session[:token]
    redirect_to login_prompt_path if token.nil?
    return !token.nil?
  end

  # Returns an API object.
  def get_adwords_api()
    @api ||= create_adwords_api()
    return @api
  end

  # Creates an instance of AdWords API class. Uses a configuration file and
  # Rails config directory.
  def create_adwords_api()
    config_filename = File.join(Rails.root, 'config', 'adwords_api.yml')
    @api = AdwordsApi::Api.new(config_filename)
    token = session[:token]
    # If we have an OAuth2 token in session we use the credentials from it.
    if token
      credentials = @api.credential_handler()
      credentials.set_credential(:oauth2_token, token)
      credentials.set_credential(:client_customer_id, selected_account)
    end
    return @api
  end
  def request_budgets_list()
    api = get_adwords_api()
    service = api.service(:BudgetService, get_api_version())
    selector = {
      :fields => ['BudgetId', 'BudgetName'],
      :ordering => [{:field => 'BudgetId', :sort_order => 'ASCENDING'}],
      :paging => {:start_index => 0, :number_results => PAGE_SIZE}
    }
    result = nil
    begin
      result = service.get(selector)
    rescue AdwordsApi::Errors::ApiException => e
      logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
      flash.now[:alert] =
          'API request failed with an error, see logs for details'
    end
    return result
  end
  
  def request_campaigns_list()
    api = get_adwords_api()
    service = api.service(:CampaignService, get_api_version())
    selector = {
      :fields => ['Id', 'Name', 'Status'],
      :ordering => [{:field => 'Id', :sort_order => 'ASCENDING'}],
      :paging => {:start_index => 0, :number_results => PAGE_SIZE}
    }
    result = nil
    begin
      result = service.get(selector)
    rescue AdwordsApi::Errors::ApiException => e
      logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
      flash.now[:alert] =
          'API request failed with an error, see logs for details'
    end
    return result
  end
end
