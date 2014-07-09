class AdGroupsController < ApplicationController
  # GET /ad_groups
  # GET /ad_groups.json
  def index
    @ad_groups = AdGroup.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @ad_groups }
    end
  end

  # GET /ad_groups/1
  # GET /ad_groups/1.json
  def show
    @ad_group = AdGroup.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ad_group }
    end
  end

  # GET /ad_groups/new
  # GET /ad_groups/new.json
  def new
    @ad_group = AdGroup.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ad_group }
    end
  end

  # GET /ad_groups/1/edit
  def edit
    @ad_group = AdGroup.find(params[:id])
  end

  # POST /ad_groups
  # POST /ad_groups.json
  def create
		if !AdGroup.find_by_name(params[:ad_group_name]) then
			@ad_group = AdGroup.new()
			@ad_group.name = params[:ad_group_name]
			keys = params[:keywords].split("\n") unless !params[:keywords]
			l_keys = params[:loc_keywords].split("\n") unless !params[:loc_keywords]
			keys.each do |key|
				if key!="" then
					k = Keyword.new
					k.value = key
					if key[0]=='"'
						k.match = "phrase"
					elsif key[0]=='['
						k.match = "exact"
					elsif key.include? "+"
						k.match = "broad modifier"
					else
						k.match = "broad"
					end
					k.location = false
					k.ad_group = @ad_group
					k.save
				end
			end
			l_keys.each do |key|
				if key!="" then
					k = Keyword.new
					k.value = key
					k.match = "broad modifer"
					k.location = true
					k.ad_group = @ad_group
					k.save
				end
			end
		end
		
		flash[:notice] = "New ad group successfully created" if @ad_group.save
		
		respond_to do |format|
			format.html {redirect_to "/home/index"}
		end
    

    #respond_to do |format|
    #  if @ad_group.save
    #    format.html { redirect_to @ad_group, notice: 'Ad group was successfully created.' }
    #    format.json { render json: @ad_group, status: :created, location: @ad_group }
    #  else
    #    format.html { render action: "new" }
    #    format.json { render json: @ad_group.errors, status: :unprocessable_entity }
    #  end
    #end
  end

  # PUT /ad_groups/1
  # PUT /ad_groups/1.json
  def update
    @ad_group = AdGroup.find(params[:id])

    respond_to do |format|
      if @ad_group.update_attributes(params[:ad_group])
        format.html { redirect_to @ad_group, notice: 'Ad group was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ad_group.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ad_groups/1
  # DELETE /ad_groups/1.json
  def destroy
    @ad_group = AdGroup.find(params[:id])
    @ad_group.destroy

    respond_to do |format|
      format.html { redirect_to ad_groups_url }
      format.json { head :no_content }
    end
  end
  
  def new_generic_ad_group
	end
	
	def add_keys
		@ad_group = AdGroup.find(params[:ad_group_id])
		keys = params[:keywords].split("\n") unless !params[:keywords]
		keys.each do |key|
				if key!="" then
					k = Keyword.new
					k.value = key
					if key[0]=='"'
						k.match = "phrase"
					elsif key[0]=='['
						k.match = "exact"
					elsif key.include? "+"
						k.match = "broad modifier"
					else
						k.match = "broad"
					end
					k.location = false
					k.ad_group = @ad_group
					k.save
				end
			end unless !keys
		
		respond_to do |format|
			format.html {render partial: 'show'}
		end
		
	end

	def del_key
		k = Keyword.find(params[:keyword_id])
		@ad_group = k.ad_group
		k.destroy
		
		respond_to do |format|
			format.html {render partial: 'show'}
		end
		
	end
	
	def make_loc
		k = Keyword.find(params[:keyword_id])
		puts "KEYWORD: ", k.value if k.match.include? "broad"
		@ad_group = k.ad_group
		if k.match.include? "broad"
			k.location = true
			k.save
		else
			#flash[:notice] = "Must be broad match or broad match modifier to make location"
		end
		
		respond_to do |format|
			format.html {render partial: 'show'}
		end
		
	end
	
	def show_keys
		group_id = params[:ad_group_id]
		puts "AD GROUP ID:", group_id
		group_id["show"]=""
		@ad_group = AdGroup.find(group_id)
		@keywords = @ad_group.keywords
		
		respond_to do |format|
			format.html {render partial: 'keys'}
		end
	end
	
	def close_keys
		@ad_group = AdGroup.find(params[:ad_group_id])
		
		respond_to do |format|
			format.html {render partial: 'group'}
		end
	end
	
end
