class Budget
  attr_reader :id
  attr_reader :name

  def initialize(api_budget)
    @id = api_budget[:budget_id]
    @name = api_budget[:name]
  end

  def self.get_budgets_list(response)
    result = {}
    if response[:entries]
      response[:entries].each do |api_budget|
        budget = Budget.new(api_budget)
        result[budget.id] = budget
      end
    end
    return result
  end
end
