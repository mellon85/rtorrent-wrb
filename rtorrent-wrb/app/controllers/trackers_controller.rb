class TrackersController < ApplicationController
  # GET /trackers
  # GET /trackers.xml
  def index
    @trackers = Trackers.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @trackers }
    end
  end

  # GET /trackers/1
  # GET /trackers/1.xml
  def show
    @trackers = Trackers.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @trackers }
    end
  end

  # GET /trackers/new
  # GET /trackers/new.xml
  def new
    @trackers = Trackers.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @trackers }
    end
  end

  # GET /trackers/1/edit
  def edit
    @trackers = Trackers.find(params[:id])
  end

  # POST /trackers
  # POST /trackers.xml
  def create
    @trackers = Trackers.new(params[:trackers])

    respond_to do |format|
      if @trackers.save
        flash[:notice] = 'Trackers was successfully created.'
        format.html { redirect_to(@trackers) }
        format.xml  { render :xml => @trackers, :status => :created, :location => @trackers }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @trackers.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /trackers/1
  # PUT /trackers/1.xml
  def update
    @trackers = Trackers.find(params[:id])

    respond_to do |format|
      if @trackers.update_attributes(params[:trackers])
        flash[:notice] = 'Trackers was successfully updated.'
        format.html { redirect_to(@trackers) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @trackers.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /trackers/1
  # DELETE /trackers/1.xml
  def destroy
    @trackers = Trackers.find(params[:id])
    @trackers.destroy

    respond_to do |format|
      format.html { redirect_to(trackers_url) }
      format.xml  { head :ok }
    end
  end
end
