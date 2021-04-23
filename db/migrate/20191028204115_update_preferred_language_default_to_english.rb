class UpdatePreferredLanguageDefaultToEnglish < ActiveRecord::Migration[5.2]
  class Language < ActiveRecord::Base; end
  class Need < ActiveRecord::Base; end

  def up
    english_language = Language.find_by(name: 'English')
    if english_language
      needs = Need.where(preferred_language_id: nil)
      needs.update_all(preferred_language_id: english_language.id)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end

end

