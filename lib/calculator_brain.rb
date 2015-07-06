module CalculatorBrain
  
  OPERATORS = ["+", "-", "*", "/"]

  LEVELS = {
    #level => [no. of operators, highest OPERATORS index, max_num]
    1 => [2, 2, 9],
    2 => [2, 1, 99],
    3 => [3, 3, 9],
    4 => [3, 2, 99],
    5 => [3, 3, 99],
  }

  def generate_expression(user)
    level = calculate_level(user)
    
    expression = rand_num(level[2])
    level[0].times do 
      expression += rand_operator(level[1])
      expression += rand_num(level[2])
    end
    expression
  end

  def calculate_level(user)
    LEVELS[user.score/100 + 1]
  end

  def rand_num(max_num)
    %(#{Random.rand(max_num + 1)})
  end

  def rand_operator(max_index)
    %(#{OPERATORS[Random.rand(max_index + 1)]})
  end

end
