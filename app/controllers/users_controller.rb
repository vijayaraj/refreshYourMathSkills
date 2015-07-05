require "calculator_brain.rb"

class UsersController < ApplicationController
  include CalculatorBrain

  before_filter :check_email, :user_exists?, :only => [:create, :reset_passcode]
  before_filter :check_passcode, :user_by_passcode, 
      :except => [:new, :create, :reset_passcode, :instructions, :routing_error]
  before_filter :check_max_score, :only => [:kickoff, :answer]
  before_filter :previous_question, :only => :answer

  def new
    @user = User.new
    render :text => I18n.t('welcome_msg')
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      render :text => I18n.t('enroll_msg', :name => @user.name, 
        :passcode => @user.passcode)
    else
      render :text => I18n.t('enroll_failure')
    end
  end

  def kickoff
    render :text => I18n.t('question', :question => generate_question)
  end

  def resume
    render :text => I18n.t('question', :question => @user.prev_question)
  end

  def answer
    answer = eval(@prev_question)
    next_question = generate_question
    
    if params[:answer].to_s == answer.to_s
      @user.update_score(User::POINTS[:right])
      render :text => I18n.t('right_ans', :question => next_question)
    else
      @user.update_score(User::POINTS[:wrong])
      render :text => I18n.t('wrong_ans', :question => next_question)
    end
  end

  def leave
    @user.prev_question = nil
    @user.passcode = nil
    
    if @user.save
      render :text => I18n.t('bye')
    end
  end

  def reset_passcode
    return render :text => I18n.t('user_not_found') unless @user
  end

  def score
    render :text => I18n.t('score_msg', :score => @user.score)
  end

  def instructions
    render :text => I18n.t('instructions')
  end

  def routing_error
    return render :text => I18n.t('no_url')
  end

  private
    def check_email
      unless params.include?('email')
        return render :text => I18n.t('no_email_msg')
      end 
    end

    def user_exists?
      @user = User.find_by_email(params[:email])
      
      if @user
        @user.set_passcode
        return render :text => I18n.t('enroll_msg', :name => @user.name, 
          :passcode => @user.passcode) + I18n.t('enroll_score_msg', :score => @user.score)
      end
    end

    def check_passcode
      unless params.include?('passcode')
        return render :text => I18n.t('no_passcode_msg')
      end
    end

    def user_by_passcode
      @user = User.find_by_passcode(params[:passcode])
      return render :text => I18n.t('user_not_found') unless @user
    end

    def check_max_score
      return render :text => I18n.t('max_score_reached') if @user.score >= User::MAX_SCORE
    end

    def generate_question
      question = generate_expression(@user)
      @user.update_attributes(:prev_question => question)
      question
    end

    def previous_question
      @prev_question = @user.prev_question
      return render :text => I18n.t('no_prev_question') unless @prev_question
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.permit(:name, :email, :passcode, :score, 
        :total_questions, :prev_question)
    end

end
