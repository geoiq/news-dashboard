module AtlasesHelper

  def how_many_new_map_list_fields?(atlas)
    [atlas.map_lists.length + 1, 3].max - atlas.map_lists.length
  end

end
