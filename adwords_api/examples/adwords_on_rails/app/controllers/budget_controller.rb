class BudgetController < ApplicationController

  PAGE_SIZE = 50

  def index()
    @selected_account = selected_account

    if @selected_account
      response = request_budgets_list()
      if response
        @budgets = Budget.get_budgets_list(response)
        @budget_count = response[:total_num_entries]
      end
    end
  end
  
  def create()
  end
  
  def new_budget()
	budget = {}
	budget[:name] = params[:budget_name]
	budget[:amount] = {:micro_amount => params[:budget_amount].to_i*1000000}
	budget[:delivery_method] = 'STANDARD'
	budget[:period] = 'DAILY'
	create_new_budget(budget)
  end
  
  private
  
  def create_new_budget(budget)
	api = get_adwords_api()
	service = api.service(:BudgetService, get_api_version())
	operation = [{:operator=>'ADD', :operand=>budget}]
	begin
      result = service.mutate(operation)
    rescue AdwordsApi::Errors::ApiException => e
      logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
      flash.now[:alert] =
          'API request failed with an error, see logs for details'
    end
    respond_to do |format|
	  format.html {redirect_to '/home/index'}
	end
  end
end
