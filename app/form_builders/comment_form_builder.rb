class CommentFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :raw, :fa_icon, :concat, to: :@template

  def text_area_with_submit(name, *args)
    options = args.last.is_a?(Hash) ? args.last : {}
    options.merge!("minlength" => 20)
    content_tag(:div, class: 'section') do
      concat(
        label(name, options[:label].to_s.html_safe, class: "field prepend-icon") do
          concat text_area(name, *args)
          concat label(name, fa_icon(options[:icon] || :user), class: "field-icon")
        end
      )
      concat(
        content_tag(:span, class: "input-footer") do
          concat content_tag(:button, "Add Comment", class: "btn btn-xs btn-primary", type: :submit)
          concat raw(" &nbsp; &nbsp; ")
          concat content_tag(:em, nil, class: "error", style: "display: none")
        end
      )
    end
  end
end
