class UserFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :fa_icon, :concat, :root_url, to: :@template

  %w[text_field password_field email_field text_area].each do |method_name|
    define_method(method_name) do |name, *args|
      options = args.last.is_a?(Hash) ? args.last : {}
      content_tag :div, class: "form-group form-group-default #{"required" if options[:required]}" do
        label(name, options[:label].to_s.html_safe) + super(name, *args)
          # content_tag(:div, class: "input-group transparent") do
          #   content_tag(:span, name, class: "input-group-addon") do
          #     fa_icon(options[:icon] || :user)
          #   end + super(name, *args)
          # end
      end
    end
  end

  def label_for_profile
    username_str = object.new_record? ? "..." : object.username
    content_tag :div, class: "section userProfileBox-info" do
      concat(
        content_tag(:label, class: "field-label text-muted") do
          "Your profile #{object.new_record? ? 'will be' : 'is'} available at:"
        end
      )
      concat(
        content_tag(:label, class: "field-label text-dark url") do
          concat root_url
          concat content_tag(:span, username_str, class: "text-primary")
        end
      )
    end
  end

  def switch_box(name, *args)
    label_html   = args.last.delete(:label_html) if args.last.is_a?(Hash)
    label_html ||= {}
    html_classes = "switch switch-primary input-align mt10 #{label_html[:class]}"
    label name, label_html.merge(class: html_classes) do
      check_box(name, *args)
    end
  end

  def check_box(name, *args)
    super + empty_label(name, data: { on: 'YES', off: 'NO' }) +
      content_tag(:span) do
      name.to_s.titleize
    end
  end

  def submit(name, *args)
    args = merge_classes(*args)
    super(name, *args)
  end

  private

  # NOTE: there seemed to be no way to create an empty label,
  # except to return empty string from the block.
  def empty_label(name, *args)
    label(name, *args){ '' }
  end

  def merge_classes(*args)
    options = args.extract_options!
    options[:class] = "button btn-primary mr10 pull-right #{options[:class]}"
    args.push(options)
    args
  end
end
