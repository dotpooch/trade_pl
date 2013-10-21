module SecuritiesHelper

  def clean_alternates(_list)
    _list.size > 1 ? _list.delete_at(0).join(",") : nil
  end

end
