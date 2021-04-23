# frozen_string_literal: true

class NeedPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || user_in_office?
  end

  def create?
    user.admin? || (user_in_office? && user.scheduler?)
  end

  def new?
    user.admin? || user.scheduler?
  end

  def edit?
    create?
  end

  def update?
    create?
  end

  def destroy?
    create?
  end

  def mark_unavailable?
    show?
  end

  def view_responses?
    create?
  end

  def permitted_attributes_for_create
    permitted_attributes | %i(office_id start_at expected_duration)
  end

  def permitted_attributes
    [:race_id, :preferred_language_id, :notes, social_worker_ids: [],
     children_attributes: %i(id _destroy age sex notes)]
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.where(office_id: user.office_ids)
      end
    end
  end

  private

  def user_in_office?
    record.office&.user_ids&.include? user.id
  end
end
