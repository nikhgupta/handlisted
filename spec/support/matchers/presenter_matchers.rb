RSpec::Matchers.define :be_a_presenter_for do |object, klass|
  match do |presented|
    klass ||= "#{object.class}Presenter".constantize
    expect(presented).to be_a(klass)
    # `model` is private method on presenter
    expect(presented.send(:model)).to eq(object)
  end
end
