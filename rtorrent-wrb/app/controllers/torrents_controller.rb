class TorrentsController < ApplicationController
  # GET /torrents
  # GET /torrents.xml
  def index
    @torrents = Torrent.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @torrents }
    end
  end

  # GET /torrents/1
  # GET /torrents/1.xml
  def show
    @torrent = Torrent.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @torrent }
    end
  end

  # GET /torrents/new
  # GET /torrents/new.xml
  def new
    @torrent = Torrent.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @torrent }
    end
  end

  # GET /torrents/1/edit
  def edit
    @torrent = Torrent.find(params[:id])
  end

  # POST /torrents
  # POST /torrents.xml
  def create
    @torrent = Torrent.new(params[:torrent])

    respond_to do |format|
      if @torrent.save
        flash[:notice] = 'Torrent was successfully created.'
        format.html { redirect_to(@torrent) }
        format.xml  { render :xml => @torrent, :status => :created, :location => @torrent }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @torrent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /torrents/1
  # PUT /torrents/1.xml
  def update
    @torrent = Torrent.find(params[:id])

    respond_to do |format|
      if @torrent.update_attributes(params[:torrent])
        flash[:notice] = 'Torrent was successfully updated.'
        format.html { redirect_to(@torrent) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @torrent.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /torrents/1
  # DELETE /torrents/1.xml
  def destroy
    @torrent = Torrent.find(params[:id])
    @torrent.destroy

    respond_to do |format|
      format.html { redirect_to(torrents_url) }
      format.xml  { head :ok }
    end
  end
end
