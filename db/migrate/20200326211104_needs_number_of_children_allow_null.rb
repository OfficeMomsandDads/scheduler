class NeedsNumberOfChildrenAllowNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :needs, :number_of_children, true
  end
end
