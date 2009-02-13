class FilelistsController < ApplicationController
  # GET /filelists
  # GET /filelists.xml
  def index
    @filelists = Filelist.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @filelists }
    end
  end

  # GET /filelists/1
  # GET /filelists/1.xml
  def show
    @filelist = Filelist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @filelist }
    end
  end

  # GET /filelists/new
  # GET /filelists/new.xml
  def new
    @filelist = Filelist.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @filelist }
    end
  end

  # GET /filelists/1/edit
  def edit
    @filelist = Filelist.find(params[:id])
  end

  # POST /filelists
  # POST /filelists.xml
  def create
    @filelist = Filelist.new(params[:filelist])

    respond_to do |format|
      if @filelist.save
        flash[:notice] = 'Filelist was successfully created.'
        format.html { redirect_to(@filelist) }
        format.xml  { render :xml => @filelist, :status => :created, :location => @filelist }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @filelist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /filelists/1
  # PUT /filelists/1.xml
  def update
    @filelist = Filelist.find(params[:id])

    respond_to do |format|
      if @filelist.update_attributes(params[:filelist])
        flash[:notice] = 'Filelist was successfully updated.'
        format.html { redirect_to(@filelist) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @filelist.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /filelists/1
  # DELETE /filelists/1.xml
  def destroy
    @filelist = Filelist.find(params[:id])
    @filelist.destroy

    respond_to do |format|
      format.html { redirect_to(filelists_url) }
      format.xml  { head :ok }
    end
  end
end
