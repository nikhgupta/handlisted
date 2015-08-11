class UserFormBuilder < ActionView::Helpers::FormBuilder
  delegate :content_tag, :tag, :fa_icon, to: :@template

  %w[text_field password_field email_field text_area].each do |method_name|
    define_method(method_name) do |name, *args|
      options = args.last.is_a?(Hash) ? args.last : {}
      content_tag :div, class: 'section' do
        label(name, options[:label].to_s.html_safe, class: "field-label text-muted fs18 mb10") +
          label(name, class: "field prepend-icon") do
          super(name, *args) + label(name, fa_icon(options[:icon] || :user), class: "field-icon")
        end
      end
    end
  end

  def switch_box(name, *args)
    html_classes = "switch ib switch-primary pull-left input-align mt10"
    label name, class: html_classes do
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
