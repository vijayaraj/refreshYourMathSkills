class User < ActiveRecord::Base
  
  validates :email, presence: true, uniqueness: true

  PASSCODE_LENGTH = 10
  POINTS = {
    :right => 10,
    :wrong => -10
  }
  MAX_SCORE = 500

  before_create :set_default_score
  after_create :set_passcode

  def set_passcode
    self.update_attributes(:passcode => SecureRandom.urlsafe_base64(PASSCODE_LENGTH))
  end

  def update_score(points)
    self.update_attributes(:score => (score + points), :total_questions => total_questions+1)
  end

  private
    def set_default_score
      self.score = 0
      self.total_questions = 0
    end
end
