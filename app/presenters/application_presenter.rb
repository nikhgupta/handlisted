class ApplicationPresenter
  def initialize(object, template)
    @object = object
    @template = template
  end

  def markdown(text)
    renderer  = Redcarpet::Render::HTML.new no_links: false, no_styles: true, no_images: true
    extension = { autolink: true, tables: false, no_intra_emphasis: true, disable_indented_code_blocks: true }
    markdown  = Redcarpet::Markdown.new renderer, extension
    markdown.render(text).strip
  end

  # tiny magic to allow:
  # - presenter code to refer to object via its name, e.g. `user`
  # - instantiating presenter from a method on object, e.g. `user.presenter_for(view)`
  #
  # Note: disabled for now, since changes on object are not reflected on
  # presenter, when presenter is created using: `object.presenter_for(view)`
  #
  # def self.inherited(name)
  #   name = name.to_s.gsub(/Presenter$/, '').underscore
  #   klass, object_klass = self, name.to_s.camelize.constantize

  #   define_method(name){ @object }
  #   object_klass.send(:define_method, :presenter_for) do |view|
  #     klass.new(self, view)
  #   end
  # end

private

  def self.presents(name)
    define_method(name){ @object }
  end

  def h
    @template
  end

  def model
    @object
  end

  def method_missing(*args, &block)
    return super unless @object.respond_to?(*args)
    @object.send(*args, &block)
  end

  def respond_to?(method, include_private = false)
    super || @object.respond_to?(method, include_private)
  end
end
