class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.all
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
    @langs = HTTParty.get('http://api.hackerrank.com/checker/languages.json')
    @names = @langs["languages"]["names"]
    @codes = @langs["languages"]["codes"]
    # byebug
    # @ques=Question.find(params[:questions_id])
    # @question=Question.where(id: params[:id]).first
  end

  def evaluate
    # byebug
    v=params.permit("quesid")
    permitted = params.permit("source","lang","testcases","api_key","format")
    response = HTTParty.post("http://api.hackerrank.com/checker/submission.json",:body => permitted);
    @val=JSON.parse(response.body)
    # return redirect_to '/solve'
    subm=Submission.new
    subm.code=permitted["source"]
    subm.user_id=current_user.id;
    # byebug
    subm.question_id=params=v["quesid"]
    subm.isCorrect=false
    subm.save!
    @err=response.code
    @res=@val["result"]["stdout"];
    @cases=params["outtestcases"]
    # render '/solve'
    # byebug

  end

  # GET /questions/new
  def new
    @question = Question.new
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    @question = Question.new(question_params)

    respond_to do |format|
      if @question.save
        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      params.require(:question).permit(:title, :content, :constraint, :inputtestcases, :outputtestcases, :marks, :difficulty, :tag)
    end
end
