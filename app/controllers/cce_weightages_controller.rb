class CceWeightagesController < ApplicationController
  before_filter :login_required
  filter_access_to :all
  def index
    @weightages=CceWeightage.all
  end

  def new
    @criteria=['FA','SA']
    @exam_categories=CceExamCategory.all
    @weightage=CceWeightage.new
  end

  def create
    @weightage=CceWeightage.new(params[:cce_weightage])
    if @weightage.save
      flash[:notice]="Weightage created successfully."
      @weightages=CceWeightage.all
    else
      @error=true
    end
  end

  def show
    @weightage=CceWeightage.find(params[:id])
    @courses=@weightage.courses
  end
  
  def edit
    @weightage=CceWeightage.find(params[:id])
    @criteria=['FA','SA']
    @exam_categories=CceExamCategory.all
  end

  def update
    @weightage=CceWeightage.find(params[:id])
    @weightage.attributes=params[:cce_weightage]
    if @weightage.save
      flash[:notice]="Weightage updated successfully."
      @weightages=CceWeightage.all
    else
      @error=true
    end
  end

  def destroy
    @weightage=CceWeightage.find(params[:id])
    if @weightage.destroy
      flash[:notice]="Weightage deleted."
    else
      flash[:notice]="Weightage could be deleted."
    end
    redirect_to :action => "index"
  end

  def assign_courses
    @weightage=CceWeightage.find(params[:id])
    @courses=Course.active
    if request.post?
      new_courses = params[:cce_weightage][:course_ids] if params[:cce_weightage]
      new_courses ||= []
      @weightage.courses = Course.find_all_by_id(new_courses)
      flash[:notice] = "saved"
      redirect_to ""
    end
  end

  def assign_weightages
    @courses=Course.cce
  end

  def select_weightages
    if request.post?
      @course=Course.find(params[:course_id])
      @course_weightages=@course.observation_groups
      @weightages=CceWeightage.all
      render(:update) do |page|
        page.replace_html 'flash-box',""
        page.replace_html 'error-div',""
        page.replace_html 'select_weightages',:partial=>"select_weightage"
      end
    end
  end

  def update_course_weightages
    @course=Course.find(params[:id])
    new_weightages = params[:course][:weightage_ids] if params[:course]
    new_weightages ||= []
    @course.cce_weightages = CceWeightage.find_all_by_id(new_weightages)
    @course_weightages=@course.cce_weightages
    @weightages=CceWeightage.all
    if @course.save
      flash[:notice] = "CCE weightages for the couse assigned successfully."
      render :js=>"window.location='/cce_weightages/assign_weightages'"
    else
      @error_object=@course
      render(:update) do |page|
        page.replace_html 'error-div',:partial=>"layouts/errors"
        page.replace_html 'select_weightages',:partial=>"select_weightage"
      end
    end
    
  end

end