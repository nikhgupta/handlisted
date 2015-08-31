ActiveAdmin.register Category do
  index do
    selectable_column
    id_column
    column :name
    column :children_count
    column :products_count
    actions
  end
end
