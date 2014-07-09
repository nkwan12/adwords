class CampaignController < ApplicationController

  PAGE_SIZE = 50

  def index()
    @selected_account = selected_account

    if @selected_account
      response = request_campaigns_list()
      if response
        @campaigns = Campaign.get_campaigns_list(response)
        @campaign_count = response[:total_num_entries]
      end
    end
  end
  
  def create()
	@selected_account = selected_account

    if @selected_account
      response = request_budgets_list()
      if response
        @budgets = Budget.get_budgets_list(response)
        @budget_count = response[:total_num_entries]
      end
    end
  end
  
  def add_ad_group()
	@selected_account = selected_account

    if @selected_account
      response = request_campaigns_list()
      if response
        @campaigns = Campaign.get_campaigns_list(response)
        @campaign_count = response[:total_num_entries]
      end
    end
    if @selected_account
      response = request_budgets_list()
      if response
        @budgets = Budget.get_budgets_list(response)
        @budget_count = response[:total_num_entries]
      end
    end
    @ad_groups = AdGroup.all
   end
   
  def new_campaign()
	campaign = {}
	campaign[:name] = params[:campaign_name]
	campaign[:budget] = {:budget_id => params[:campaign_budget]}
	campaign[:status] = 'PAUSED'
	campaign[:bidding_strategy_configuration] = {:bidding_strategy_type => 'MANUAL_CPC'}
	campaign[:settings] = [ {:xsi_type => 'KeywordMatchSetting', :opt_in => true} ]
	create_new_campaign(campaign)
  end
  
  def new_campaign_and_ads
		campaign = {}
		campaign[:name] = params[:campaign_name]
		campaign[:budget] = {:budget_id => params[:campaign_budget]}
		campaign[:status] = 'PAUSED'
		campaign[:bidding_strategy_configuration] = {:bidding_strategy_type => 'MANUAL_CPC'}
		campaign[:settings] = [ {:xsi_type => 'KeywordMatchSetting', :opt_in => true} ]
		create_new_campaign(campaign)
		new_ad_groups()
  end
  
  def new_ad_groups()
		adwords = AdwordsApi::Api.new
		ad_group_srv = adwords.service(:AdGroupService, :v201402)
		ad_group_criterion_srv = adwords.service(:AdGroupCriterionService, :v201402)
		keywords = []
		ags = []
		aw_ags = []
		aw_ag_ids = []
		group_ids = params[:ad_group_ids]
		group_ids.each do |ad_group_id|
			ad_group_id["_:id__"] = ""
			ad_group_id["_"] = ""
			ag = AdGroup.find(ad_group_id)
			ags << ag
			aw_ag = { :name=>ag.name, :status=>'ENABLED', :campaign_id=>params[:campaign_id], :bidding_strategy_configuration => 
				{
					:bids => [
						{
							:xsi_type => 'CpcBid',
							:bid => {:micro_amount => 10000000}
						}
					]
				} }
			aw_ags << aw_ag
		end
		
		ag_operations = aw_ags.map do |ad_group|
			{:operator => 'ADD', :operand => ad_group}
		end
		
		ag_response = ad_group_srv.mutate(ag_operations)
		
		if ag_response[:value] then
			ag_response[:value].each do |v|
				aw_ag_ids << v[:id]
			end
		end
		
		locs = params[:locations].split("\n") unless !params[:locations]
		
		(0...ags.length).each do |i|
			ags[i].keywords.each do |key|
				val = key.value
				if key.match == "phrase" then
					while val['"'] do
						val['"'] = ''
					end
				end
				if key.match == "exact" then
					val['['] = ''
					val[']'] = ''
				end
				match = 'BROAD'
				if !key.match.include? "broad" then match = key.match.upcase end
				if key.location and locs[0]
					locs.each do |loc|
						loc = loc.split(" ")
						loc = loc.join(" +")
						loc = " +"+loc
						keywords << { :xsi_type => 'BiddableAdGroupCriterion',
							:ad_group_id => aw_ag_ids[i],
							:criterion => {
							:xsi_type => 'Keyword',
							:text => val+loc,
							:match_type => match
							}
						}
					end
				else
					keywords << { :xsi_type => 'BiddableAdGroupCriterion',
						:ad_group_id => aw_ag_ids[i],
						:criterion => {
						:xsi_type => 'Keyword',
						:text => val,
						:match_type => match
						}
					}
				end
			end
		end
		
		
		key_operations = keywords.map do |k|
			{:operator => 'ADD', :operand => k}
		end
		
		response = ad_group_criterion_srv.mutate(key_operations)
		
		respond_to do |format|
			format.html {redirect_to home_index_path}
		end
  end
	

  private

  def create_new_campaign(campaign)
	api = get_adwords_api()
	service = api.service(:CampaignService, get_api_version())
	operation = [{:operator=>'ADD', :operand=>campaign}]
	begin
      result = service.mutate(operation)
      params[:campaign_id] = result[:value][0][:id]
    rescue AdwordsApi::Errors::ApiException => e
      logger.fatal("Exception occurred: %s\n%s" % [e.to_s, e.message])
      flash.now[:alert] =
          'API request failed with an error, see logs for details'
    end
    #respond_to do |format|
		#	format.html {redirect_to '/home/index'}
		#end
  end
end
