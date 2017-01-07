module AddProductHelpers
  def expect_search_to(*args)
    within(".overlay"){ expect(page).to(*args) }
  end

  def expect_search_not_to(*args)
    within(".overlay"){ expect(page).not_to(*args) }
  end

  def expect_search_to_show_message(message)
    selector = ".overlay-content p strong"
    expect_search_to have_selector(selector, count: 1, text: message)
  end

  def add_product(user, url)
    pid, url = PRODUCTS_LIST[url][:pid], PRODUCTS_LIST[url][:url]
    ProductScraperJob.perform_async user.id, url
    ProductScraperJob.drain
    product = Product.find_by(pid: pid)
    expect(product).to be_persisted
    product
  end

  def fill_sitewide_search_with(url)
    fill_in :search, with: ""
    find('input#overlay-search').native.send_keys :backspace

    # fill_in :search, with: url
    find('input#overlay-search').native.send_keys url
    find('input#overlay-search').native.send_keys :backspace if url.blank?
  end

  def add_product_to_sitewide_search(url)
    url = PRODUCTS_LIST[url] ? PRODUCTS_LIST[url][:url] : url.to_s
    click_on_link "anywhere to search"

    fill_sitewide_search_with(url)
    url
  end

  def add_product_via_sitewide_search(url, instant: true, &block)
    url = add_product_to_sitewide_search(url)
    find('input#overlay-search').native.send_keys :Enter unless instant

    url.blank? ? assert_not_running_ajax : assert_running_ajax
    wait_for_traffic
    assert_not_running_ajax

    within(".overlay"){ yield } if block_given?
  end
  alias :search_using_sitewide_search :add_product_via_sitewide_search

  def assert_running_ajax
    expect(page).to have_selector ".ajax-loader img"
  end

  def assert_not_running_ajax
    expect(page).to have_no_selector ".ajax-loader img"
  end

  def progress_status
    bar = find("nav.header .progress-bar:not([aria-valuenow='0'])")
    bar["aria-valuenow"].to_i if bar
  end

  def click_for_product_info_modal(product)
    selector = card_selector_for(product) + " .image-container"
    find(selector).trigger("click")
  end

  # Add a product by given URL (or symbol), ensures that the Queued status is
  # reflected, and optionally, accepts a block to execute before the real
  # execution of job.
  #
  def add_product_via_search_and_perform(url, instant: true, &block)
    add_product_via_sitewide_search(url, instant: instant)
    click_on_link "Import Product" if instant
    expect(page).to have_selector('nav.header .progress-bar-master')
    expect(progress_status).to be >= 10
    expect(ProductScraperJob.jobs.size).to eq 1
    yield if block_given?
    ProductScraperJob.drain
    sleep 2
  ensure
    wait_for_traffic
  end

  def card_selector_for(product)
    ".product.card[data-pid='#{product.pid}']"
  end

  def toggle_like_for_product(*args)
    selector = card_selector_for(*args) + " a.product-like"
    find(selector).trigger 'click'
    wait_for_traffic
  end

  def like_status_for(*args)
    selector = card_selector_for(*args) + " a.product-like"
    find(selector)['class'].include? 'active'
  end

  def add_likers_for_product(product, count = 2)
    create_list(:confirmed_user, count).each do |user|
      user.like product
    end
  end
end
